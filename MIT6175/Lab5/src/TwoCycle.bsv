// TwoCycle.bsv
//
// This is a two cycle implementation of the RISC-V processor.

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

typedef enum {
	Fetch,
	Execute
} Stage deriving(Bits, Eq, FShow);


(* synthesize *)
module mkProc(Proc);
    Reg#(Addr) pc <- mkRegU;    RFile      rf <- mkRFile;
    IMemory  iMem <- mkIMemory; DMemory  dMem <- mkDMemory;
    
    Reg#(Stage) stage <- mkReg(Fetch);

    Reg#(Data) f2d <- mkRegU;

    CsrFile  csrf <- mkCsrFile;
    Bool memReady = iMem.init.done() && dMem.init.done();
    rule initMem (!memReady);
        let e = tagged InitDone;
        iMem.init.request.put(e);
        dMem.init.request.put(e);
    endrule

    rule doStage1(csrf.started && (stage==Fetch) && memReady);
        $display("in stage 1");
        // S1 IF
        // typedef Bit#(DataSz) Data;
        // fetch Bit#(DataSz) instruction
        Data inst = iMem.req(pc);
        f2d <= inst;
        stage <= Execute;
    endrule

    rule doStage2(csrf.started && (stage==Execute) && memReady);
        $display("in stage 2");
        let inst = f2d;
        // S2 ID
        // decode instruction
        DecodedInst dInst = decode(inst);
        // read general purpose register values
        Data rVal1 = rf.rd1(fromMaybe(?, dInst.src1));
        Data rVal2 = rf.rd2(fromMaybe(?, dInst.src2));
        // read CSR values (for CSRR inst)
        Data csrVal = csrf.rd(fromMaybe(?, dInst.csr));

        // S3 EX
        // execute
        ExecInst eInst = exec(dInst, rVal1, rVal2, pc, ?, csrVal);  
		// The fifth argument above is the predicted pc, to detect if it was mispredicted. 
		// Since there is no branch prediction, this field is sent with a random value


        // S4 MEM
        // memory
        if(eInst.iType == Ld) begin
            eInst.data <- dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
        end else if(eInst.iType == St) begin
            let d <- dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
        end

		// commit

        // trace - print the instruction
        $display("pc: %h inst: (%h) expanded: ", pc, inst, showInst(inst));
	    $fflush(stdout);

        // check unsupported instruction at commit time. Exiting
        if(eInst.iType == Unsupported) begin
            $fwrite(stderr, "ERROR: Executing unsupported instruction at pc: %x. Exiting\n", pc);
            $finish;
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

    interface iMemInit = iMem.init;
    interface dMemInit = dMem.init;
endmodule

(* synthesize *)
module mkTb();
    Proc fifo <-mkProc();
endmodule