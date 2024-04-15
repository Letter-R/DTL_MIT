
import GetPut::*;
import ClientServer::*;
import Memory::*;
import CacheTypes::*;
import WideMemInit::*;
import MemUtil::*;
import Vector::*;
import CacheTypes::*;
import Types::*;
import Fifo::*;
import MemTypes::*;
//
// interface Cache;
//     method Action req(MemReq r);
//     method ActionValue#(MemResp) resp;
// endinterface

// typedef Vector#(CacheLineWords, Data) CacheLine;

// Cache 
// 8 lines, index                           16 * 32
// | [state] 2^2    | [tag] 2^23 |    [data block] 2^9=512    |
//                                         
// Addr
// |    tag 23             |       index 3           |   word_in_line 4  |  00 word 2   |
//   max 2^23 512 block         3 for 8 lines           4 for 16 words in one line     2 for 4 bit 

typedef enum {
    Invalid,       // init, no data
    Valid,         // read  data, same as mem 
    Dirty          // write data, need to be write, then to Valid
} LineState deriving (Bits, Eq);

typedef struct{
    LineState   state;
    CacheTag    tag;
    CacheLine   data;   // vector 16,32
} CacheBlock deriving(Bits, Eq);

typedef enum {
    Ready,           // init, can read and write
    WaitMemResp,      // if read miss, mem.req
    Resp
} CacheState deriving (Bits, Eq);

module mkCache(WideMem wideMem, Cache ifc);
    // cache
    Vector#(CacheRows, Reg#(CacheBlock)) storage <- replicateM(mkReg(CacheBlock{state:Invalid, tag:?, data:?}));

    Reg#(CacheState) cacheState <- mkReg(Ready);

    // I/O of cache
    // Fifo#(2, Addr) memReqFifo  <- mkPipelineFifo();
    // Fifo#(2, Addr) respDataFifo <- mkPipelineFifo();


    Fifo#(2, Addr) addrFifo <- mkPipelineFifo();

    function CacheTag        getTag(Addr addr) = truncateLSB(addr);
    function CacheIndex      getIndex(Addr addr) = truncate(addr >> 6);
    function CacheWordSelect getOffset(Addr addr) = truncate(addr >> 2);


    // WaitMemResp
    rule doMem2Cache (cacheState == WaitMemResp);
        // typedef Vector#(CacheLineWords 16, Data 32) CacheLine;
        let memcacheline <- wideMem.resp();
        let addr = addrFifo.first();
        let idx = getIndex(addr);
        let tag = getTag(addr);
        if ((storage[idx].state == Invalid) || (storage[idx].state == Valid)) begin
            storage[idx] <= CacheBlock{
                state: Valid, 
                tag:   tag, 
                data:  memcacheline};
        end else if (storage[idx].state == Dirty) begin
            // todo
        end

        cacheState <= Resp;
    endrule

    // rule doResp;
    //     let addr = addrFifo.first();    // Bit#(32)
    //     addrFifo.deq();
    //     let idx = getIndex(addr);       // Bit#(3)
    //     let offset = getOffset(addr);   // Bit#(4)
    //     let data = storage[idx].data[offset];
    //     respDataFifo.enq(data);
    // endrule

    method Action req(MemReq r) if (cacheState == Ready);
        let  idx = getIndex(r.addr);
        let  tag = getTag(r.addr);
        Bool hit = ((tag == storage[idx].tag) && (storage[idx].state != Invalid));
        if (hit) begin
            // cacheline <= storage[idx];
            $display("cache hit");
            if(r.op == Ld) begin
                addrFifo.enq(r.addr);
                cacheState <= Resp;
            end else if (r.op == St) begin
                // todo
            end
        end else begin
            // 
            $display("cache miss");
            //
            if(r.op == Ld) begin
                //
                let w = toWideMemReq(r);
                wideMem.req(w);
                // 
                cacheState <= WaitMemResp;
                //
                addrFifo.enq(r.addr);
            end else if (r.op == St) begin
                // todo
            end
        end
    endmethod
    


    // typedef CacheLine WideMemResp;
    // interface WideMem;
    //     method Action req(WideMemReq r);
    //     method ActionValue#(CacheLine) resp;
    // endinterface
    //
    // typedef Data MemResp;
    //                       16         32

    method ActionValue#(MemResp) resp if (cacheState == Resp);
        cacheState <= Ready;
        let addr = addrFifo.first();    // Bit#(32)
        addrFifo.deq();
        let idx = getIndex(addr);       // Bit#(3)
        let offset = getOffset(addr);   // Bit#(4)
        return storage[idx].data[offset];
    endmethod


endmodule



// typedef enum{Ld, St} MemOp deriving(Eq, Bits, FShow);
// typedef struct{
//     MemOp op;
//     Addr  addr;
//     Data  data;
// } MemReq deriving(Eq, Bits, FShow);

module mkTranslator(WideMem mem, Cache ifc);

    // typedef CacheLine WideMemResp;
    // interface WideMem;
    //     method Action req(WideMemReq r);
    //     method ActionValue#(CacheLine) resp;
    // endinterface
    //
    // Wide memory interface
    // This is defined here since it depends on the CacheLine type
    // typedef struct{
    //     Bit#(CacheLineWords) write_en;  // Word write enable
    //     Addr                 addr;
    //     CacheLine            data;      // Vector#(CacheLineWords, Data)
    // } WideMemReq deriving(Eq,Bits);
    Fifo#(2, Addr) addrFifo <- mkPipelineFifo();
    
    method Action req(MemReq r);
        if(r.op == Ld) begin
            addrFifo.enq(r.addr);
        end
        // function WideMemReq toWideMemReq( MemReq req );
        let w = toWideMemReq(r);
        
        mem.req(w);
    endmethod
    

    // typedef CacheLine WideMemResp;
    // interface WideMem;
    //     method Action req(WideMemReq r);
    //     method ActionValue#(CacheLine) resp;
    // endinterface
    //
    // typedef Data MemResp;
    //                       16         32
    // typedef Vector#(CacheLineWords, Data) CacheLine;
    method ActionValue#(MemResp) resp;
        let cacheline <- mem.resp();
        let addr = addrFifo.first();
        addrFifo.deq();
        CacheWordSelect wordSelect = truncate(addr >> 2);
        return cacheline[wordSelect];

    endmethod


endmodule

