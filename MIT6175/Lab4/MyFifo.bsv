import Ehr::*;
import Vector::*;
import RegFile::*;

//////////////////
// Fifo interface 

interface Fifo#(numeric type n, type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

// Exercise 1
// Conflict Fifo
module mkMyConflictFifo(Fifo#(n,t)) provisos (Bits#(t, a__));
    Vector#(n,Reg#(t)) data <- replicateM(mkRegU());
    Reg#(Bit#(TLog#(n))) enqP <- mkReg(0);
    Reg#(Bit#(TLog#(n))) deqP <- mkReg(0);
    Reg#(Bool) notFullF <- mkReg(True);
    Reg#(Bool) notEmptyF <- mkReg(False);

    Bit#(TLog#(n)) nn =fromInteger(valueOf(n));


    method Bool notFull();
        return notFullF;
    endmethod

    method Action enq(t x) if(notFullF);
        data[enqP]<=x;
        Bit#(TLog#(n)) next_enqP=(enqP==(nn-1))?(0):(enqP+1);
        enqP<=next_enqP;
        notFullF<=(deqP!=next_enqP);
        notEmptyF<=True;
    endmethod

    method Bool notEmpty();
        return notEmptyF;
    endmethod

    method Action deq() if (notEmptyF);
        Bit#(TLog#(n)) next_deqP=(deqP==(nn-1))?(0):(deqP+1);
        deqP<=next_deqP;
        notEmptyF<=(enqP!=next_deqP);
        notFullF<=True;
    endmethod

    method t first() if (notEmptyF);
        return data[deqP];
    endmethod

    method Action clear();
        enqP <= 0;
        deqP <= 0;
        notFullF <= True;
        notEmptyF <= False;
    endmethod
endmodule


// Exercise 2

// enq
//     read:         notFullF   enqP       deqP
//     written:      notFullF   notEmptyF  data    enqP
// deq
//     read:         notEmptyF  deqP       enqP
//     written:      notFullF   notEmptyF  deqP

// deq < enq
// deq
//     read:         notEmptyF[0]  deqP[0]       enqP[1]
//     written:      notFullF[0]   notEmptyF[0]  deqP[0]
// enq
//     read:         notFullF[1]   enqP[1]       deqP[1]
//     written:      notFullF[1]   notEmptyF[1]  enqP[1]


// Pipeline FIFO
module mkMyPipelineFifo(Fifo#(n,t)) provisos (Bits#(t, a__));
    Vector#(n,Reg#(t)) data <- replicateM(mkRegU());
    Ehr#(3,Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3,Bit#(TLog#(n))) deqP <- mkEhr(0);
    Ehr#(3,Bool) notFullF <- mkEhr(True);
    Ehr#(3,Bool) notEmptyF <- mkEhr(False);

    Bit#(TLog#(n)) nn =fromInteger(valueOf(n));

    // enq
    //     read:         notFullF[1]   enqP[1]       deqP[1]
    //     written:      notFullF[1]   notEmptyF[1]  enqP[1]
    method Bool notFull();
        return notFullF[1];
    endmethod

    method Action enq(t x) if(notFullF[1]);
        data[enqP[1]]<=x;   
        Bit#(TLog#(n)) next_enqP=(enqP[1]==(nn-1))?(0):(enqP[1]+1);
        enqP[1]<=next_enqP;
        notFullF[1]<=(deqP[1]!=next_enqP);
        notEmptyF[1]<=True;
    endmethod

    // deq
    //     read:         notEmptyF[0]  deqP[0]       enqP[0]
    //     written:      notFullF[0]   notEmptyF[0]  deqP[0]
    method Bool notEmpty();
        return notEmptyF[0];
    endmethod

    method Action deq() if (notEmptyF[0]);
        Bit#(TLog#(n)) next_deqP=(deqP[0]==(nn-1))?(0):(deqP[0]+1);
        deqP[0]<=next_deqP;
        notEmptyF[0]<=(enqP[0]!=next_deqP);
        notFullF[0]<=True;
    endmethod

    // first < deq
    method t first() if (notEmptyF[0]);
        return data[deqP[0]];
    endmethod

    // 
    // 1 Reg会在下一个周期保留，所以最高位的ehrReg会保留到下一个周期，而wire中的数据不会
    // 2 由于同一索引位是先读后写，而wire要求先写才能读，就导致先读低位读到的是索引以下的最高有效位，或者上一周期的最高位ehrReg
    // 3 对于Ehr的任意位置，先读就是读最高有效位，先写后读才可以读到，当deq<enq时，deq使用[0]，enq使用[1]即可
    // 4 clear要重置[2]而不能重置[1]是因为，如果重置[1]，[1]的wire是有效的，此时enq读取会读到[1]而不是deq写入的[0]位置
    method Action clear();
        enqP[2] <= 0;
        deqP[2] <= 0;
        notFullF[2] <= True;
        notEmptyF[2] <= False;
    endmethod
endmodule


// Bypass FIFO
module mkMyBypassFifo(Fifo#(n,t)) provisos (Bits#(t, a__));
    Vector#(n,Reg#(t)) data <- replicateM(mkRegU());
    Ehr#(3,Bit#(TLog#(n))) enqP <- mkEhr(0);
    Ehr#(3,Bit#(TLog#(n))) deqP <- mkEhr(0);
    Ehr#(3,Bool) notFullF <- mkEhr(True);
    Ehr#(3,Bool) notEmptyF <- mkEhr(False);

    Bit#(TLog#(n)) nn =fromInteger(valueOf(n));

    // enq
    //     read:         notFullF[0]   enqP[0]       deqP[0]
    //     written:      notFullF[0]   notEmptyF[0]  enqP[0]
    method Bool notFull();
        return notFullF[0];
    endmethod

    method Action enq(t x) if(notFullF[0]);
        data[enqP[0]]<=x;   
        Bit#(TLog#(n)) next_enqP=(enqP[0]==(nn-1))?(0):(enqP[0]+1);
        enqP[0]<=next_enqP;
        notFullF[0]<=(deqP[0]!=next_enqP);
        notEmptyF[0]<=True;
    endmethod

    // deq
    //     read:         notEmptyF[1]  deqP[1]       enqP[1]
    //     written:      notFullF[1]   notEmptyF[0]  deqP[1]
    method Bool notEmpty();
        return notEmptyF[1];
    endmethod

    method Action deq() if (notEmptyF[1]);
        Bit#(TLog#(n)) next_deqP=(deqP[1]==(nn-1))?(0):(deqP[1]+1);
        deqP[1]<=next_deqP;
        notEmptyF[1]<=(enqP[1]!=next_deqP);
        notFullF[1]<=True;
    endmethod

    // first < deq
    method t first() if (notEmptyF[0]);
        return data[deqP[1]];
    endmethod

    method Action clear();
        enqP[2] <= 0;
        deqP[2] <= 0;
        notFullF[2] <= True;
        notEmptyF[2] <= False;
    endmethod
endmodule



// Conflict-free FIFO
module mkMyCFFifo(Fifo#(n,t)) provisos (Bits#(t, a__));
    // data
    Vector#(n,Reg#(t)) data <- replicateM(mkRegU());
    // regs, update at each canonicalize
    Reg#(Bit#(TLog#(n))) enqP <- mkReg(0);
    Reg#(Bit#(TLog#(n))) deqP <- mkReg(0);
    Reg#(Bool) notFullF <- mkReg(True);
    Reg#(Bool) notEmptyF <- mkReg(False);
    // flag of method active
    // deq和enq互不影响
    // 本周期读取Reg，写入位置0
    // canonicalize读取位置1,写入Reg
    Ehr#(2,Maybe#(t)) venq <- mkEhr(tagged Invalid);
    Ehr#(2,Bool) vdeq <- mkEhr(False);
    Ehr#(2,Bool) vclear <- mkEhr(False);

    Bit#(TLog#(n)) nn = fromInteger(valueOf(n));
    
    (* no_implicit_conditions *)
    (* fire_when_enabled *)
    rule canonicalize ( True );
        // reset flags
        venq[1] <= tagged Invalid;
        vdeq[1] <= False;
        vclear[1] <= False;

        Bit#(TLog#(n)) next_deqP=(deqP==(nn-1))?(0):(deqP+1);
        Bit#(TLog#(n)) next_enqP=(enqP==(nn-1))?(0):(enqP+1);

        if (vclear[1]) begin                            // clear
            // reset regs
            enqP <= 0;
            deqP <= 0;
            notFullF <= True;
            notEmptyF <= False;
        end else if (isValid(venq[1]) && vdeq[1]) begin //enq+deq
            data[enqP] <= fromMaybe(?, venq[1]);
            enqP <= next_enqP;
            deqP <= next_deqP;
        end else if (isValid(venq[1])) begin            //enq
            data[enqP] <= fromMaybe(?, venq[1]);
            enqP <= next_enqP;

            notFullF <= (next_enqP!=deqP);
            notEmptyF <= True;
        end else if (vdeq[1]) begin                     //deq
            deqP <= next_deqP;

            notFullF <= True;
            notEmptyF <= (next_deqP!=enqP);
        end
    endrule

    method Bool notFull();
        return notFullF;
    endmethod

    method Action enq(t x) if(notFullF);
        venq[0] <= tagged Valid x;
    endmethod

    method Bool notEmpty();
        return notEmptyF;
    endmethod

    method Action deq() if (notEmptyF);
        vdeq[0] <= True;
    endmethod

    method t first() if (notEmptyF);
        return data[deqP];
    endmethod

    method Action clear();
        vclear[0] <= True;
    endmethod
endmodule


