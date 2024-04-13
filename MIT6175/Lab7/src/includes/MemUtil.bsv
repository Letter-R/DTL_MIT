import Types::*;
import ProcTypes::*;
import MemTypes::*;
import CacheTypes::*;
import Fifo::*;
import Vector::*;
import Memory::*;

function Bit#(TMul#(n,4)) wordEnToByteEn( Bit#(n) word_en );
    Bit#(TMul#(n,4)) byte_en;
    for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
        for( Integer j = 0 ; j < 4 ; j = j+1 ) begin
            byte_en[ 4*i + j ] = word_en[i];
        end
    end
    return byte_en;
endfunction

function Bit#(wordSize) selectWord( Bit#(TMul#(numWords,wordSize)) line, Bit#(TLog#(numWords)) sel ) provisos ( Add#( a__, TLog#(numWords), TLog#(TMul#(numWords,wordSize))) );
    Bit#(TLog#(TMul#(numWords,wordSize))) index_offset = zeroExtend(sel) * fromInteger(valueOf(wordSize));
    return line[ index_offset + fromInteger(valueOf(wordSize)-1) : index_offset ];
endfunction

// 0100 -> 01000100
function Bit#(TMul#(wordSize,numWords)) replicateWord( Bit#(wordSize) word ) provisos ( Add#( a__, wordSize, TMul#(wordSize,numWords)) );
    Bit#(TMul#(wordSize,numWords)) x = 0;
    for( Integer i = 0 ; i < valueOf(numWords) ; i = i+1 ) begin
        x[ valueOf(wordSize)*(i+1) - 1 : valueOf(wordSize)*(i) ] = word;
    end
    return x;
endfunction



function WideMemReq toWideMemReq( MemReq req );
    Bit#(CacheLineWords) write_en = 0;              // read default
    CacheWordSelect wordsel = truncate( req.addr >> 2 );    // 
    // set byte_en, which 
    if( req.op == St ) begin
        write_en = 1 << wordsel;
    end
    Addr addr = req.addr;
    for( Integer i = 0 ; i < valueOf(TLog#(CacheLineBytes)) ; i = i+1 ) begin
        addr[i] = 0;
    end
    CacheLine data = replicate( req.data );

    return WideMemReq {
                write_en: write_en,
                addr: addr,
                data: data
            };
endfunction


// typedef enum{Ld, St} MemOp deriving(Eq, Bits, FShow);
// typedef struct{
//     MemOp op;
//     Addr  addr;  // Bit#(32)
//     Data  data;  // Bit#(32)
// } MemReq deriving(Eq, Bits, FShow);
//
// typedef struct {
//     Bool        write;
//     Bit#(64)    byteen;
//     Bit#(24)    address;
//     Bit#(512)   data;
// } DDR3_Req deriving (Bits, Eq);
//
// one cache has 8row * 16 * word(4 bit) = 512bit
// riscv addr is 32 bit, 2^32 bits
// cache addr is 24 bit, 2^24 times 2^9 (512)bit 
function DDR3_Req toDDR3Req( MemReq req );
    Bool write = (req.op == St);
    // index of word(4 bit) of 512
    // Bit#( TLog#(CacheLineWords) ) CacheWordSelect
    // Bit#(4), index of word(4 bit) in a cache row
    CacheWordSelect wordSelect = truncate(req.addr >> 2);
    // mask of word(4 bit) index
    // Bit#(64), each bit for a Byte
    // Bit#(4) is 0-15
    DDR3ByteEn byteen = wordEnToByteEn( 1 << wordSelect );
	if( req.op == Ld ) begin
		byteen = 0;
	end
    // req.addr >> valueOf(TLog#(DDR3DataBytes))
    // aligen ddr3Bytes, index of ddr3Bytes Bit#(512)
    DDR3Addr addr = truncate( req.addr >> valueOf(TLog#(DDR3DataBytes)) );
    DDR3Data data = replicateWord(req.data);
    return DDR3_Req {
                write:      (req.op == St),
                byteen:     byteen,
                address:    addr,
                data:       data
            };
endfunction

module mkWideMemFromDDR3(   Fifo#(2, DDR3_Req) ddr3ReqFifo,
                            Fifo#(2, DDR3_Resp) ddr3RespFifo,
                            WideMem ifc );
    method Action req( WideMemReq x );
        Bool write_en = (x.write_en != 0);
        Bit#(DDR3DataBytes) byte_en = wordEnToByteEn(x.write_en);
		if( write_en == False ) begin
			byte_en = 0;
		end
        // x.addr is byte aligned and ddr3 addresses are aligned to DDR3Data sized blocks
        DDR3Addr addr = truncate(x.addr >> valueOf(TLog#(DDR3DataBytes)));

        DDR3_Req ddr3_req = DDR3_Req {
                                write:      write_en,
                                byteen:     byte_en,
                                address:    addr,
                                data:       pack(x.data)
                            };
        ddr3ReqFifo.enq( ddr3_req );
        $display("mkWideMemFromDDR3::req : wideMemReq.addr = 0x%0x, ddr3Req.address = 0x%0x, ddr3Req.byteen = 0x%0x", x.addr, ddr3_req.address, ddr3_req.byteen);
    endmethod
    method ActionValue#(WideMemResp) resp;
        let x = ddr3RespFifo.first;
        ddr3RespFifo.deq;
        $display("mkWideMemFromDDR3::resp : data = 0x%0x", x.data);
        return unpack(x.data);
    endmethod
endmodule

module mkSplitWideMem(  Bool initDone, WideMem mem,
                        Vector#(n, WideMem) ifc );

    Vector#(n, Fifo#(2, WideMemReq)) reqFifos <- replicateM(mkCFFifo);
    Fifo#(TAdd#(n,1), Bit#(TLog#(n))) reqSource <- mkCFFifo;
    Vector#(n, Fifo#(2, WideMemResp)) respFifos <- replicateM(mkCFFifo);

    rule doDDR3Req(initDone);
        Maybe#(Bit#(TLog#(n))) req_index = tagged Invalid;
        for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
            if( !isValid(req_index) && reqFifos[i].notEmpty ) begin
                req_index = tagged Valid (fromInteger(i));
            end
        end

        if( isValid(req_index) ) begin
            let req = reqFifos[ fromMaybe(?,req_index) ].first;
            reqFifos[ fromMaybe(?,req_index) ].deq();

            mem.req(req);
            if( req.write_en == 0 ) begin
                // req is a load, so keep track of the source
                reqSource.enq( fromMaybe(?,req_index) );
            end
        end
    endrule

    rule doDDR3Resp(initDone);
        let resp <- mem.resp;

        let source = reqSource.first;
        reqSource.deq;

        respFifos[source].enq( resp );
    endrule

    Vector#(n, WideMem) wideMemIfcs = newVector;
    for( Integer i = 0 ; i < valueOf(n) ; i = i+1 ) begin
        wideMemIfcs[i] =
            (interface WideMem;
                method Action req( WideMemReq x );
                    reqFifos[i].enq(x);
                endmethod
                method ActionValue#(WideMemResp) resp;
                    let x = respFifos[i].first;
                    respFifos[i].deq;
                    return x;
                endmethod
            endinterface);
    end
    return wideMemIfcs;
endmodule
