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
    //     read:         notEmptyF[0]  deqP[0]       enqP[1]
    //     written:      notFullF[0]   notEmptyF[0]  deqP[0]
    method Bool notEmpty();
        return notEmptyF[0];
    endmethod

    method Action deq() if (notEmptyF[0]);
        Bit#(TLog#(n)) next_deqP=(deqP[0]==(nn-1))?(0):(deqP[0]+1);
        deqP[0]<=next_deqP;
        notEmptyF[0]<=(enqP[1]!=next_deqP);
        notFullF[0]<=True;
    endmethod

    // first < deq
    method t first() if (notEmptyF[0]);
        return data[deqP[0]];
    endmethod

    // 
    method Action clear();
        enqP[2] <= 0;
        deqP[2] <= 0;
        notFullF[2] <= True;
        notEmptyF[2] <= False;
    endmethod
endmodule