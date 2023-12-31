import Ehr::*;
import Vector::*;

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
