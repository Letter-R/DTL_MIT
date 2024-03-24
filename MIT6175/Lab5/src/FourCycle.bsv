// FourCycle.bsv
//
// This is a four cycle implementation of the RISC-V processor.

// TwoCycle.bsv
//
// This is a two cycle implementation of the RISC-V processor.

import Types::*;
import ProcTypes::*;
import CMemTypes::*;
import RFile::*;
import DelayedMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Vector::*;
import Fifo::*;
import Ehr::*;
import GetPut::*;

typedef enum {
	Fetch,
    Decode,
	Execute,
    WriteBack
} Stage deriving(Bits, Eq, FShow);

typedef struct {
    DecodedInst dInst;
    Data rVal1;
    Data rVal2;
    Data csrVal;
} Mess2 deriving(Bits, Eq, FShow);

(* synthesize *)
module mkProc(Proc);
    Reg#(Addr) pc <- mkRegU;    
    RFile      rf <- mkRFile;
    DelayedMemory  mem <- mkDelayedMemory; 
    
    Reg#(Stage) stage <- mkReg(Fetch);

    // Reg#(Data) mess1 <- mkRegU;
    Reg#(Mess2) mess2 <- mkRegU;
    Reg#(ExecInst) mess3 <- mkRegU;

    CsrFile  csrf <- mkCsrFile;

    Bool memReady = mem.init.done();
    rule initMem (!memReady);
        let e = tagged InitDone;
        mem.init.request.put(e);
    endrule

    rule doStage1(csrf.started && (stage==Fetch) && memReady);
        $display("in stage 1");
        // S1 IF
        // typedef Bit#(DataSz) Data;
        // fetch Bit#(DataSz) instruction
        mem.req(MemReq{op:Ld,addr:pc,data:?});
        // mess1 <= inst;
        stage <= Decode;
    endrule

    rule doStage2(csrf.started && (stage==Decode) && memReady);
        $display("in stage 2");
        let inst <- mem.resp();
        // S2 ID
        // decode instruction
        DecodedInst dInst = decode(inst);
        // read general purpose register values
        Data rVal1 = rf.rd1(fromMaybe(?, dInst.src1));
        Data rVal2 = rf.rd2(fromMaybe(?, dInst.src2));
        // read CSR values (for CSRR inst)
        Data csrVal = csrf.rd(fromMaybe(?, dInst.csr));

        stage <= Execute;
        mess2 <= Mess2{dInst: dInst, rVal1: rVal1, rVal2: rVal2, csrVal: csrVal};

        // trace - print the instruction
        $display("pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));
	    $fflush(stdout);

    endrule

    rule doStage3(csrf.started && (stage==Execute) && memReady);
        let dInst = mess2.dInst;
        let rVal1 = mess2.rVal1;
        let rVal2 = mess2.rVal2;
        let csrVal = mess2.csrVal;

        // S3 EX
        // execute
        ExecInst eInst = exec(dInst, rVal1, rVal2, pc, ?, csrVal);  


        // S4 MEM
        // memory
        if(eInst.iType == Ld) begin
            mem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
        end else if(eInst.iType == St) begin
            mem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
        end

        // check unsupported instruction at commit time. Exiting
        if(eInst.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pc);
            $finish;
        end
        mess3 <= eInst;
        stage <= WriteBack;
    endrule

    rule doStage4(csrf.started && (stage==WriteBack) && memReady);
        let eInst = mess3;

        if(eInst.iType == Ld) begin
            eInst.data <- mem.resp();
        end
    
        // S5 WB
        // write back to reg file
        if(isValid(eInst.dst)) begin
            rf.wr(fromMaybe(?, eInst.dst), eInst.data);
        end

        // update the pc depending on whether the branch is taken or not
        pc <= eInst.brTaken ? eInst.addr : pc + 4;

        // CSR write for sending data to host & stats
        csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);

        stage <= Fetch;
    endrule

    method ActionValue#(CpuToHostData) cpuToHost;
        let ret <- csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
        csrf.start(0); // only 1 core, id = 0
        $display("Start at pc 200\n");
        $fflush(stdout);
        pc <= startpc;
    endmethod

    interface iMemInit = mem.init;
    interface dMemInit = mem.init;
endmodule


(* synthesize *)
module mkTb();
    Proc fifo <-mkProc();
endmodule