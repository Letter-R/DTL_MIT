import FIFO::*;
import FixedPoint::*;
import Vector::*;

import AudioProcessorTypes::*;
import FilterCoefficients::*;
import Multiplier::*;

// The FIR Filter Module Definition
module mkFIRFilter (AudioProcessor);
    // two fifo for audio data
    FIFO#(Sample) infifo <- mkFIFO();
    FIFO#(Sample) outfifo <- mkFIFO();
    // 8 Reg
    Vector#(8, Reg#(Sample)) r <- replicateM(mkReg(0));
    // 9 multiplier
    Vector#(9, Multiplier) m <- replicateM(mkMultiplier);

    rule mul (True);
        // keep read in_data
        Sample sample = infifo.first();
        infifo.deq();
        // shift taps
        r[0] <= sample;
        for(Integer i=0;i<7;i=i+1) begin
            r[i+1]<=r[i];
        end

        m[0].putOperands(c[0],sample);
        for(Integer i=1;i<9;i=i+1) begin
            m[i].putOperands(c[i],r[i-1]);
        end
    endrule

    rule add ( True );
        Vector#(9,FixedPoint#(16,16)) res;
        res[0]<-m[0].getResult();
        for(Integer i=1;i<9;i=i+1) begin
            let x<-m[i].getResult();
            res[i]=res[i-1]+x;
        end
        // out accumulated data
        outfifo.enq(fxptGetInt(res[8]));
    endrule 

    method Action putSampleInput(Sample in);
        infifo.enq(in);
    endmethod

    method ActionValue#(Sample) getSampleOutput();
        outfifo.deq();
        return outfifo.first();
    endmethod
endmodule
