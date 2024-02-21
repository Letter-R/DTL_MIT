import FIFO::*;
import FixedPoint::*;
import Vector::*;

import AudioProcessorTypes::*;

import Multiplier::*;

// The FIR Filter Module Definition
module mkFIRFilter (Vector#(tnp1, FixedPoint#(16, 16)) coeffs, AudioProcessor ifc);
    // two fifo for audio data
    FIFO#(Sample) infifo <- mkFIFO();
    FIFO#(Sample) outfifo <- mkFIFO();
    // 8 Reg
    Vector#(TSub#(tnp1, 1), Reg#(Sample)) r <- replicateM(mkReg(0));
    // 9 multiplier
    Vector#(tnp1, Multiplier) m <- replicateM(mkMultiplier);

    rule mul (True);
        // keep read in_data
        Sample sample = infifo.first();
        infifo.deq();
        // shift taps
        r[0] <= sample;
        for(Integer i=0;i<(valueOf(tnp1)-2);i=i+1) begin
            r[i+1]<=r[i];
        end

        m[0].putOperands(coeffs[0],sample);
        for(Integer i=1;i<valueOf(tnp1);i=i+1) begin
            m[i].putOperands(coeffs[i],r[i-1]);
        end
    endrule

    rule add ( True );
        Vector#(tnp1,FixedPoint#(16,16)) res;
        res[0]<-m[0].getResult();
        for(Integer i=1;i<valueOf(tnp1);i=i+1) begin
            let x<-m[i].getResult();
            res[i]=res[i-1]+x;
        end
        // out accumulated data
        outfifo.enq(fxptGetInt(res[valueOf(TSub#(tnp1, 1))]));
    endrule 

    method Action putSampleInput(Sample in);
        infifo.enq(in);
    endmethod

    method ActionValue#(Sample) getSampleOutput();
        outfifo.deq();
        return outfifo.first();
    endmethod
endmodule
