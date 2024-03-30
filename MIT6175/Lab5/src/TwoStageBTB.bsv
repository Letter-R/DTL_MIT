// TwoStage.bsv
//
// This is a two stage pipelined implementation of the RISC-V processor.

import Types::*;
import ProcTypes::*;
import CMemTypes::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import GetPut::*;
import Btb::*;

typedef struct{
    DecodedInst dInst;
    Addr pc;
    Addr predPc;
} Dec2Ex deriving (Bits,Eq);

(*synthesize*)
module mkProc(Proc);
    
    Ehr#(2,Addr) pc<-mkEhr(0);
    
    RFile       rf<-mkRFile;
    IMemory     iMem<-mkIMemory;
    DMemory     dMem<-mkDMemory;
    CsrFile     csrf<-mkCsrFile;

    Fifo#(4,Dec2Ex) d2e<-mkCFFifo;

    Btb#(8) btb <- mkBtb();

    Bool memReady=iMem.init.done() && dMem.init.done();
    rule initMem (!memReady);
        let e = tagged InitDone;
        iMem.init.request.put(e);
        dMem.init.request.put(e);
    endrule


    // doFetch read pc[0] than write pc[0]
    rule doFetch(csrf.started);
        // IF
        Data            inst=iMem.req(pc[0]);
        Dec2Ex          dec2exe;
        dec2exe.pc      =pc[0];
        // ID
        dec2exe.dInst   =decode(inst);
        // predict
        let predPc      =btb.predPc(pc[0]);
        dec2exe.predPc  =predPc;
        pc[0]<=predPc;

        $display("pc:%h inst:(%h) expanded: ",dec2exe.pc,inst,showInst(inst));
        $fflush(stdout);

        d2e.enq(dec2exe);
        
    endrule

    rule doExecute(csrf.started);
        // read DecodedInst dInst, Addr pc, Addr predPc
        Dec2Ex dec2exe = d2e.first;
        d2e.deq();

        // prepare execute instruction info
        Data        rVal1=rf.rd1(fromMaybe(?,dec2exe.dInst.src1));
        Data        rVal2=rf.rd2(fromMaybe(?,dec2exe.dInst.src2));
        Data        csrVal=csrf.rd(fromMaybe(?,dec2exe.dInst.csr));
        // eInst.mispredict get here
        ExecInst    eInst=exec(
            dec2exe.dInst,
            rVal1,rVal2,
            dec2exe.pc,dec2exe.predPc,
            csrVal
            );

        // data memory
        if(eInst.iType==Ld) begin
            eInst.data<-dMem.req(MemReq{op:Ld,addr:eInst.addr,data:?});    
        end else if(eInst.iType==St) begin
            let dummy<-dMem.req(MemReq{op:St,addr:eInst.addr,data:eInst.data});
        end

        // register file
        if(isValid(eInst.dst)) begin
            rf.wr(fromMaybe(?,eInst.dst),eInst.data);
        end

        csrf.wr(eInst.iType==Csrw?eInst.csr:Invalid,eInst.data);

        // handle mispredict
        if(eInst.mispredict) begin
            $display("Mispredict!");
            $fflush(stdout);

            d2e.clear();        // clear d2e
            pc[1]<=eInst.addr;  // cover pc, real next pc addr
            btb.update(dec2exe.pc, eInst.addr);
        end else begin
            $display("Right Predict!");
            $fflush(stdout);

            
        end
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret<-csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if(!csrf.started&&memReady);
        csrf.start(0);
        $display("STARTING AT PC: %h", startpc);
	    $fflush(stdout);
        pc[0]<=startpc;
    endmethod

    interface iMemInit=iMem.init;
    interface dMemInit=dMem.init;
endmodule
