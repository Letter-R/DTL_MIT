
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


// module mkPitchAdjust(Integer s, FixedPoint#(isize, fsize) factor, PitchAdjust#(nbins, isize, fsize, psize) ifc) provisos(
//     Add#(psize, a__, isize),
//     Add#(TLog#(nbins), b__, isize),
//     Add#(c__, psize, TAdd#(isize, isize)),
//     Min#(TAdd#(isize, fsize), 2, 2),
//     Min#(TAdd#(isize, isize), 1, 1)
// );
    
//     // TODO: implement this module 

//     FIFO#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) inp <- mkFIFO();
//     FIFO#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) outp <- mkFIFO();

//     Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) in <- mkRegU();
//     Reg#(Vector#(nbins, ComplexMP#(isize, fsize, psize))) out <- mkRegU();

//     Reg#(Vector#(nbins, Phase#(psize))) inphases <- mkReg(replicate(tophase(0)));
//     Reg#(Vector#(nbins, Phase#(psize))) outphases <- mkReg(replicate(tophase(0)));

//     Reg#(Bit#(TLog#(nbins))) cnt <- mkReg(0);
//     Reg#(Bool) running <- mkReg(False);


//     rule do_pitch (running==True);

//         let phase = in[cnt].phase;
//         let mag = in[cnt].magnitude;

//         let dphase = phase - inphases[cnt];
//         inphases[cnt] <= phase;

//         Bit#(isize) t = zeroExtend(cnt);
//         FixedPoint#(isize, fsize) fp_cnt = fromInt(unpack(t));

        
//         // TODO can use accumlate to replace multiple
//         let bin = fxptGetInt(fp_cnt * factor);
//         let nbin = fxptGetInt((fp_cnt + 1) * factor);
        

//         if (nbin != bin && bin >= 0 && bin < nbin) begin
//             FixedPoint#(isize, fsize) fp_dphase = fromInt(dphase);
//             // use * instead of fxptMult will fail.
//             let shifted = truncate(fxptGetInt(fxptMult(fp_dphase, factor)));
//             outphases[bin] <= outphases[bin] + shifted;
//             out[bin] <= cmplxmp(mag, outphases[bin]+ shifted);
//         end

//         if (cnt == fromInteger(valueOf(nbins)-1) ) begin
//             running <= False;
//         end else begin
//             cnt <= cnt + 1;
//         end

//     endrule

//     rule input_request(running == False && cnt == 0);
//         inp.deq;
//         in <= inp.first;
//         running <= True;
//         out <= unpack(0);
//     endrule

//     rule output_result(running == False && cnt == fromInteger(valueOf(nbins)-1));
//         cnt <= 0;
//         outp.enq(out);
//     endrule
 

//     interface Put request = toPut(inp);
//     interface Get response = toGet(outp);

// endmodule
