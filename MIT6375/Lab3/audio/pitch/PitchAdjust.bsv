
import ClientServer::*;
import FIFO::*;
import GetPut::*;

import FixedPoint::*;
import Vector::*;

import ComplexMP::*;


typedef Server#(
    Vector#(nbins, ComplexMP#(isize, fsize, psize)),
    Vector#(nbins, ComplexMP#(isize, fsize, psize))
) PitchAdjust#(numeric type nbins, // the number of points of the FFT used to produce the complex numbers
            numeric type isize,    // the number of bits to use for the integer part of the magnitude of the complex numbers
            numeric type fsize,    // the number of bits to use for the fractional part of the magnitude of the complex numbers
            numeric type psize);   // the number of bits to use for the phase of the complex numbers


// s - the amount each window is shifted from the previous window.
//
// factor - the amount to adjust the pitch.
//  1.0 makes no change. 2.0 goes up an octave, 0.5 goes down an octave, etc...
module mkPitchAdjust(Integer s, FixedPoint#(isize, fsize) factor, 
                PitchAdjust#(nbins, isize, fsize, psize) ifc)
            provisos(
                Add#(psize, a__, isize),
                Add#(TLog#(nbins), b__, isize),
                Add#(c__, psize, TAdd#(isize, isize)),
                Min#(TAdd#(isize, isize), 1, 1),
                Min#(TAdd#(isize, fsize), 2, 2)
            );

    // windows
    FIFO#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) inFIFO <- mkFIFO();
    FIFO#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) outFIFO <- mkFIFO();
    
    // bins of a window
    Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) in <- mkRegU();
    Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) out <- mkRegU();

    // phases in each bins of a window
    Reg#(Vector#(nbins, Phase#(psize))) inphases <- mkReg(replicate(tophase(0)));
    Reg#(Vector#(nbins, Phase#(psize))) outphases <- mkReg(replicate(tophase(0)));

    // corrent bin th
    Reg#(Bit#(TLog#(nbins))) i <- mkReg(0); 
    Reg#(Bool) finish_a_window <- mkReg(True);

    rule load_data ( i==0 && finish_a_window==True);
        in <= inFIFO.first();
		inFIFO.deq();
        finish_a_window<=False;
        out <= unpack(0);
    endrule

    rule pitchadjust (finish_a_window==False);
        // parse ith bin data
        Phase#(psize) phase = phaseof(in[i]);
        FixedPoint#(isize, fsize) mag = in[i].magnitude;

        /////////
        // $display("mag1: ", fshow(mag));

        // read before write, inphases[0]=0
        Phase#(psize) dphase = phase - inphases[i];
        inphases[i] <= phase;

        // Bit -> Int -> FixedPoint
        FixedPoint#(isize, fsize) tmp = fromInt(unpack(i));
        Int#(isize) bin = fxptGetInt(tmp * factor);
        Int#(isize) nbin = fxptGetInt((tmp + 1) * factor);

        // 
        if (nbin != bin && bin >= 0 && bin < nbin) begin
            // FixedPoint#(isize, fsize) factor
            // Phase#(psize) dphase
            FixedPoint#(isize, fsize) fp_dphase = fromInt(dphase);
            Phase#(psize) shifted = truncate(fxptGetInt(fxptMult(fp_dphase, factor)));
            /////////
            // $display("mag2: ", fshow(mag));
            
            outphases[bin] <= outphases[bin] + shifted;
            out[bin] <= cmplxmp(mag, outphases[bin] + shifted);
        end

        //////
        // $display("mag3: ", fshow(out[bin].magnitude));

        if (i == fromInteger(valueOf(nbins)-1)) begin
            finish_a_window <= True;
        end else begin
            i <= i+1;
        end

    endrule

    rule out_data (i == fromInteger(valueOf(nbins)-1) && finish_a_window==True);
        i <= 0;
        outFIFO.enq(out);
        
    endrule

    interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);

endmodule

