// init six stage codes

import Types::*;
import ProcTypes::*;
import MemTypes::*;
import MemInit::*;
import RFile::*;
import Decode::*;
import Exec::*;
import CsrFile::*;
import Fifo::*;
import Ehr::*;
import Btb::*;
import Scoreboard::*;
import FPGAMemory::*;
import Ras::*;
import Cache::*;
import MemTypes::*;
import CacheTypes::*;
import Vector::*;
import Bht::*;
import MemUtil::*;

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


//    Fifo#(2, DDR3_Req)  ddr3ReqFifo <- mkCFFifo();
//    Fifo#(2, DDR3_Resp) ddr3RespFifo <- mkCFFifo();

//    DDR3_Client ddrclient = toGPClient( ddr3ReqFifo, ddr3RespFifo );
//    mkSimMem(ddrclient);

//    Proc m <- mkProc(ddr3ReqFifo,ddr3RespFifo);

// (* synthesize *)
module mkProc#(Fifo#(2, DDR3_Req)  ddr3ReqFifo, Fifo#(2, DDR3_Resp) ddr3RespFifo)(Proc);
    RFile            rf <- mkRFile;
	Scoreboard#(6)   sb <- mkCFScoreboard;
	// FPGAMemory     iMem <- mkFPGAMemory;
    // FPGAMemory     dMem <- mkFPGAMemory;
    CsrFile        csrf <- mkCsrFile;
    Btb#(6)         btb <- mkBtb; //  64-entry BTB
	Bht#(8)		    bht <- mkBht; // 256-entry BHT
	RAS#(8)			ras <- mkRas;

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

	// wrap DDR3 to WideMem interface
    WideMem           wideMemWrapper <- mkWideMemFromDDR3( ddr3ReqFifo, ddr3RespFifo );
	// split WideMem interface to two (use it in a multiplexed way) 
	// This spliter only take action after reset (i.e. memReady && csrf.started)
	// otherwise the guard may fail, and we get garbage DDR3 resp
    Vector#(2, WideMem)     wideMems <- mkSplitWideMem(csrf.started, wideMemWrapper );
	// Instruction cache should use wideMems[1]
	// Data cache should use wideMems[0]

	// some garbage may get into ddr3RespFifo during soft reset
	// this rule drains all such garbage
    rule drainMemResponses( !csrf.started );
        ddr3RespFifo.deq;
    endrule


    Cache iMem <- mkTranslator(wideMems[1]);
    Cache dMem <- mkTranslator(wideMems[0]);



	Reg#(Int#(64)) cycles <- mkReg(0);
	rule split_cycle(csrf.started);
		cycles <= cycles + 1;
		$display("--%d------------------------------------", cycles);
        // if (cycles == 150000) begin
        //     $finish;
        // end
	endrule

	// fetch
	rule doIF(csrf.started);
		iMem.req(MemReq{op:Ld, addr:pcReg[0], data:?});	
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
	rule doID(csrf.started);
		//
		let inst <- iMem.resp();
		let if2id = if2idFifo.first();
		if2idFifo.deq();

		// should fire on valid inst 
		if ((if2id.epoch3 == epoch3[0]) && (if2id.epoch2 == epoch2[0]) && (if2id.epoch1 == epoch1[0])) begin
			//
			DecodedInst dInst = decode(inst);
			let ppc = if2id.predPc;
			let jump_addr = if2id.pc+fromMaybe(?, dInst.imm);
			
			if (dInst.iType == J) begin
				if (fromMaybe(?,dInst.dst) == 1) begin
					ras.push(if2id.pc+4);
				end
				let bht_ppc =  bht.ppcDP(ppc, jump_addr);
				if (ppc != bht_ppc) begin
					ppc = bht_ppc;
					pcReg[1] <= bht_ppc;
					epoch3[0] <= !epoch3[0];
					$display("Decode: jal redirected to PC = %x", bht_ppc);
				end
			end else if (dInst.iType == Jr) begin
				// dst = 1, store pc+4 in x1, push
				if (fromMaybe(?,dInst.dst) == 1) begin
					ras.push(if2id.pc+4);
				// dst = 0, src1 = 1, pop, only JALR has src1
				end else if (isValid(dInst.dst) == False && fromMaybe(?,dInst.src1) == 1) begin
					let tmp <- ras.pop();
					let ras_ppc = fromMaybe(?,tmp);
					if (ppc != ras_ppc) begin
						ppc = ras_ppc;
						pcReg[1] <= ras_ppc;
						epoch3[0] <= !epoch3[0];
						$display("Decode: ras redirected to PC = %x", ras_ppc);
					end 
				end
				
			end else if ((dInst.iType == Br)) begin
			// if ((dInst.iType == J)) begin
				let bht_ppc =  bht.ppcDP(ppc, jump_addr);
				if (ppc != bht_ppc) begin
					ppc = bht_ppc;
					pcReg[1] <= bht_ppc;
					epoch3[0] <= !epoch3[0];
					$display("Decode: bht redirected to PC = %x", bht_ppc);
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
	rule doRF(csrf.started);
		ID2RF id2rf = id2rfFifo.first();
		DecodedInst dInst = id2rf.dInst;
		// should fire on valid inst 
		if ((id2rf.epoch2 == epoch2[0]) && (id2rf.epoch1 == epoch1[0])) begin
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
						epoch2[0] <= !epoch2[0];
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
	rule doEXE(csrf.started);
		//
		let rf2exe = rf2exeFifo.first();
		rf2exeFifo.deq();
		//
		if (rf2exe.epoch1 == epoch1[0]) begin
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
                epoch1[0] <= !epoch1[0];
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
	rule doMEM(csrf.started);
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
	rule doWB(csrf.started);
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

    method Action hostToCpu(Bit#(32) startpc) if (!csrf.started && !ddr3RespFifo.notEmpty );
	$display("Start cpu");
        csrf.start(0); // only 1 core, id = 0
        pcReg[0] <= startpc;
    endmethod

endmodule
