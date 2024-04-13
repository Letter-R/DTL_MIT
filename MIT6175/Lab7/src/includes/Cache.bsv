
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

// interface FPGAMemory;
//     method Action req(MemReq r);
//     method ActionValue#(MemResp) resp;
//     interface MemInitIfc init;
// endinterface


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







// module mkCache(Bool initDone, Fifo#(2, DDR3_Req) ddr3ReqFifo, Fifo#(2, DDR3_Resp) ddr3RespFifo, Cache ifc);



//     WideMem wideMemWrapper <- mkWideMemFromDDR3(ddr3ReqFifo, ddr3RespFifo);
//     Vector#(2, WideMem) wideMems <- mkSplitWideMem(initDone, wideMemWrapper);
//     rule drainMemResponses(!initDone);
//         ddr3RespFifo.deq;
//     endrule

// 	// Instruction cache should use wideMems[1]
// 	// Data cache should use wideMems[0]


//     method Action req(MemReq r);

//     method ActionValue#(MemResp) resp;



// endmodule