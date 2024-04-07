// change to six stage

// Instruction Fetch -- request instruction from iMem and update PC
// Decode -- receive response from iMem and decode instruction
// Register Fetch -- read from the register file
// Execute -- execute the instruction and redirect the processor if necessary
// Memory -- send memory request to dMem
// Write Back -- receive memory response from dMem (if applicable) and write to register file


import Types::*;
import ProcTypes::*;
import MemTypes::*;
import MemInit::*;
import RFile::*;
import IMemory::*;
import DMemory::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Fifo::*;
import Ehr::*;
import Btb::*;
import Scoreboard::*;
import FPGAMemory::*;
import Bht::*;

typedef struct {
    Addr pc;
    Addr predPc;
	Bool epoch1;
    Bool epoch2;
	Bool epoch3;
} IF2ID deriving (Bits, Eq);

typedef struct {
    Addr pc;
    Addr predPc;
	Bool epoch1;
    Bool epoch2;
	DecodedInst dInst;
} ID2RF deriving (Bits, Eq);

typedef struct {
    Addr pc;
    Addr predPc;
    Bool epoch1;
	DecodedInst dInst;
	Data rVal1;
	Data rVal2;
	Data csrVal;
} RF2EXE deriving (Bits, Eq);

typedef struct {
    Addr pc;
    Maybe#(ExecInst) eInst;
} EXE2MEM deriving (Bits, Eq);

typedef struct {
    Addr pc;
    Maybe#(ExecInst) eInst;
} MEM2WB deriving (Bits, Eq);

(* synthesize *)
module mkProc(Proc);
    RFile            rf <- mkRFile;
	Scoreboard#(6)   sb <- mkCFScoreboard;
	FPGAMemory     iMem <- mkFPGAMemory;
    FPGAMemory     dMem <- mkFPGAMemory;
    CsrFile        csrf <- mkCsrFile;
    Btb#(6)         btb <- mkBtb; //  64-entry BTB
	Bht#(8)		    bht <- mkBht; // 256-entry BHT

    Fifo#(6, IF2ID)    if2idFifo      <-  mkCFFifo;
    Fifo#(6, ID2RF)    id2rfFifo      <-  mkCFFifo;
    Fifo#(6, RF2EXE)   rf2exeFifo     <-  mkCFFifo;
    Fifo#(6, EXE2MEM)  exe2memFifo    <-  mkCFFifo;
    Fifo#(6, MEM2WB)   mem2wbFifo     <-  mkCFFifo;

    Ehr#(4, Addr) pcReg <- mkEhrU();	// pc, init at start

	// global epoch2 for redirection from Execute stage
	Ehr#(2, Bool) epoch1 <- mkEhr(False);
	Ehr#(2, Bool) epoch2 <- mkEhr(False);
	Ehr#(2, Bool) epoch3 <- mkEhr(False);

    Bool memReady = iMem.init.done && dMem.init.done;

	rule split_cycle(True);
		$display("--------------------------------------");
	endrule

	// fetch
	rule doIF(csrf.started && memReady);
		iMem.req(MemReq{op:?, addr:pcReg[0], data:?});	
		Addr ppc = btb.predPc(pcReg[0]);
		pcReg[0] <= ppc;
		if2idFifo.enq(
			IF2ID{
				pc: pcReg[0], 
				predPc: ppc, 
				epoch1: epoch1[0],
				epoch2: epoch2[0],
				epoch3: epoch3[0]
				}
			);
		$display("Fetch: PC = %x", pcReg[0]);
	endrule

	// decode
	rule doID(csrf.started && memReady);
		//
		let inst <- iMem.resp();
		let if2id = if2idFifo.first();
		if2idFifo.deq();

		// should fire on valid inst 
		if ((if2id.epoch3 == epoch3[1]) && (if2id.epoch2 == epoch2[1]) && (if2id.epoch1 == epoch1[1])) begin
			//
			DecodedInst dInst = decode(inst);
			let ppc = if2id.predPc;
			// // if is JAL, jump
			// if (dInst.iType == J) begin
			// 	Addr tmp_ppc = if2id.pc+fromMaybe(?, dInst.imm);
			// 	if (ppc != tmp_ppc) begin
			// 		pcReg[1] <= tmp_ppc;
			// 		ppc = tmp_ppc;
			// 		epoch3[1] <= !epoch3[1];
			// 		$display("Decode: next pc Mispredict, redirected to PC = %x", tmp_ppc);
			// 	end
			// // if is Branch, predict
			// end else if (dInst.iType == Br) begin
			// 	ppc = bht.ppcDP(ppc, if2id.pc+fromMaybe(?, dInst.imm));
			// end
			//
			// branch should change epoch too
			let jump_addr = if2id.pc+fromMaybe(?, dInst.imm);
			if ((dInst.iType == J) || (dInst.iType == Br)) begin
				let bht_ppc =  bht.ppcDP(ppc, jump_addr);
				if (ppc != bht_ppc) begin
					ppc = bht_ppc;
					pcReg[1] <= bht_ppc;
					epoch3[1] <= !epoch3[1];
					$display("Decode: redirected to PC = %x", bht_ppc);
				end
			end
			//
			id2rfFifo.enq(
				ID2RF{
					pc: if2id.pc, 
					predPc: ppc, 
					epoch1: if2id.epoch1,
					epoch2: if2id.epoch2,
					dInst: dInst
					}
				);
			$display("Decode: PC = %x, inst = %x, expanded = ", if2id.pc, inst, showInst(inst));
		end
		else begin
			$display("Decode: drop at PC = %x", if2id.pc);
		end

	endrule

	// register fetch
	rule doRF(csrf.started && memReady);
		ID2RF id2rf = id2rfFifo.first();
		DecodedInst dInst = id2rf.dInst;
		// should fire on valid inst 
		if ((id2rf.epoch2 == epoch2[1]) && (id2rf.epoch1 == epoch1[1])) begin
			// search scoreboard to determine stall
			if(!(sb.search1(dInst.src1) || sb.search2(dInst.src2))) begin
				// no stall
				id2rfFifo.deq();
				// upate sorceboard
				sb.insert(dInst.dst);
				// register read
				Data rVal1  = rf.rd1(fromMaybe(?, dInst.src1));
				Data rVal2  = rf.rd2(fromMaybe(?, dInst.src2));
				Data csrVal = csrf.rd(fromMaybe(?, dInst.csr));
				//
				let ppc = id2rf.predPc;
				// if is JALR, jump
				if (dInst.iType == Jr) begin
					Addr tmp_ppc = {truncateLSB(rVal1 + fromMaybe(?, dInst.imm)), 1'b0};
					if (ppc != tmp_ppc) begin
						pcReg[2] <= tmp_ppc;
						ppc = tmp_ppc;
						epoch2[1] <= !epoch2[1];
						$display("Fetch Register: next pc Mispredict, redirected to PC = %x", tmp_ppc);
					end
				end
				//
				rf2exeFifo.enq(
					RF2EXE{
						pc    : id2rf.pc,
						predPc: ppc,
						epoch1: id2rf.epoch1,
						dInst : id2rf.dInst,
						rVal1 : rVal1,
						rVal2 : rVal2,
						csrVal: csrVal
					}
				);
				$display("Fetch Register: PC = %x, rs1 = %x, rs2 = %x, csr = %x", id2rf.pc, rVal1, rVal2, csrVal);
			end
			else begin
				$display("Fetch Register: Stalled: PC = %x", id2rf.pc);
			end
		end
		else begin
			id2rfFifo.deq();
			$display("Fetch Register: drop at PC = %x", id2rf.pc);
		end

	endrule

	// execute
	rule doEXE(csrf.started && memReady);
		//
		let rf2exe = rf2exeFifo.first();
		rf2exeFifo.deq();
		//
		if (rf2exe.epoch1 == epoch1[1]) begin
			// execute
			ExecInst eInst = exec(
				rf2exe.dInst, rf2exe.rVal1 , rf2exe.rVal2, 
				rf2exe.pc   , rf2exe.predPc, rf2exe.csrVal);
			$display("Execute: PC = %x", rf2exe.pc);
			//
			if(eInst.iType == Unsupported) begin
				$fwrite(stderr, "Execute: ERROR: Unsupported instruction at PC = %x. Exiting\n", rf2exe.pc);
				$finish;
			end
			// handle new mispredict
			if (eInst.mispredict) begin
                pcReg[3] <= eInst.addr;
                epoch1[1] <= !epoch1[1];
				if (eInst.iType == J || eInst.iType == Jr || eInst.iType == Br) begin
					btb.update(rf2exe.pc, eInst.addr);
					bht.update(rf2exe.pc, eInst.brTaken);
				end
				$display("Execute: Mispredict, redirected to PC = %x", eInst.addr);
            end
			//
			exe2memFifo.enq(
				EXE2MEM{
					pc: rf2exe.pc, 
					eInst: Valid(eInst)
					}
				);
		end else begin
			// handle old mis-predict
			// kill wrong-path inst, just deq sb
			// sb.remove();
			// mispredic have WB stage too!
			$display("Execute: skip mis-predict instruction");
			//
			exe2memFifo.enq(
				EXE2MEM{
					pc: rf2exe.pc, 
					eInst: Invalid
					}
				);
		end
	endrule

	// data memory
	rule doMEM(csrf.started && memReady);
		//
		let exe2mem = exe2memFifo.first();
		exe2memFifo.deq();
		// memory
		if (isValid(exe2mem.eInst)) begin
            let eInst = fromMaybe(?, exe2mem.eInst);
            if(eInst.iType == Ld) begin
                dMem.req(MemReq{op: Ld, addr: eInst.addr, data: ?});
            end else if(eInst.iType == St) begin
                dMem.req(MemReq{op: St, addr: eInst.addr, data: eInst.data});
            end
            $display("Memory: PC = %x", exe2mem.pc);
			//
			mem2wbFifo.enq(
				MEM2WB{
					pc: exe2mem.pc, 
					eInst: Valid(eInst)
					}
				);
        end else begin
			//
			mem2wbFifo.enq(
				MEM2WB{
					pc: exe2mem.pc, 
					eInst: Invalid
					}
				);
            $display("Memory: skip mis-predict. PC = %x", exe2mem.pc);
        end
	endrule

	// write back
	rule doWB(csrf.started && memReady);
		//
		let mem2wb = mem2wbFifo.first();
		mem2wbFifo.deq();
		// 
		if (isValid(mem2wb.eInst)) begin
            let eInst = fromMaybe(?, mem2wb.eInst);
			//
			if(eInst.iType == Ld) begin
                eInst.data <- dMem.resp();
            end
			// write back to reg file
			if(isValid(eInst.dst)) begin
				rf.wr(fromMaybe(?, eInst.dst), eInst.data);
			end
			csrf.wr(eInst.iType == Csrw ? eInst.csr : Invalid, eInst.data);
			
            $display("WriteBack: PC = %x", mem2wb.pc);
        end else begin
            $display("WriteBack: mis-predict. PC = %x", mem2wb.pc);
        end
		// 
		sb.remove();
	endrule

    method ActionValue#(CpuToHostData) cpuToHost if(csrf.started);
        let ret <- csrf.cpuToHost;
        return ret;
    endmethod

    method Action hostToCpu(Bit#(32) startpc) if ( !csrf.started && memReady );
	$display("Start cpu");
        csrf.start(0); // only 1 core, id = 0
        pcReg[0] <= startpc;
    endmethod

	interface iMemInit = iMem.init;
    interface dMemInit = dMem.init;
endmodule

