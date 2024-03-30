
import ClientServer::*;
import Complex::*;
import FIFO::*;
import Reg6375::*;
import GetPut::*;
import Real::*;
import Vector::*;

import AudioProcessorTypes::*;

typedef Server#(
    Vector#(fft_points, ComplexSample),
    Vector#(fft_points, ComplexSample)
) FFT#(numeric type fft_points);

// Get the appropriate twiddle factor for the given stage and index.
// This computes the twiddle factor statically.
function ComplexSample getTwiddle(Integer stage, Integer index, Integer points);
    Integer i = ((2*index)/(2 ** (log2(points)-stage))) * (2 ** (log2(points)-stage));
    return cmplx(fromReal(cos(fromInteger(i)*pi/fromInteger(points))),
                 fromReal(-1*sin(fromInteger(i)*pi/fromInteger(points))));
endfunction

// Generate a table of all the needed twiddle factors.
// The table can be used for looking up a twiddle factor dynamically.
typedef Vector#(
    TLog#(fft_points), 
    Vector#(TDiv#(fft_points, 2), 
    ComplexSample)
) TwiddleTable#(numeric type fft_points);
function TwiddleTable#(fft_points) genTwiddles();
    TwiddleTable#(fft_points) twids = newVector;
    for (Integer s = 0; s < valueof(TLog#(fft_points)); s = s+1) begin
        for (Integer i = 0; i < valueof(TDiv#(fft_points, 2)); i = i+1) begin
            twids[s][i] = getTwiddle(s, i, valueof(fft_points));
        end
    end
    return twids;
endfunction

// Given the destination location and the number of points in the fft, return
// the source index for the permutation.
function Integer permute(Integer dst, Integer points);
    Integer src = ?;
    if (dst < points/2) begin
        src = dst*2;
    end else begin
        src = (dst - points/2)*2 + 1;
    end
    return src;
endfunction

// Reorder the given vector by swapping words at positions
// corresponding to the bit-reversal of their indices.
// The reordering can be done either as as the
// first or last phase of the FFT transformation.
function Vector#(fft_points, ComplexSample) bitReverse(Vector#(fft_points,ComplexSample) inVector);
    Vector#(fft_points, ComplexSample) outVector = newVector();
    for(Integer i = 0; i < valueof(fft_points); i = i+1) begin   
        Bit#(TLog#(fft_points)) reversal = reverseBits(fromInteger(i));
        outVector[reversal] = inVector[i];           
    end  
    return outVector;
endfunction

// 2-way Butterfly
function Vector#(2, ComplexSample) bfly2(Vector#(2, ComplexSample) t, ComplexSample k);
    ComplexSample m = t[1] * k;

    Vector#(2, ComplexSample) z = newVector();
    z[0] = t[0] + m;
    z[1] = t[0] - m; 

    return z;
endfunction

// Perform a single stage of the FFT, consisting of butterflys and a single
// permutation.
// We pass the table of twiddles as an argument so we can look those up
// dynamically if need be.
function Vector#(
                    fft_points, ComplexSample) stage_ft
                    (TwiddleTable#(fft_points) twiddles, 
                    Bit#(TLog#(TLog#(fft_points))) stage, 
                    Vector#(fft_points, ComplexSample) stage_in
                ) provisos(Add#(2, a__, fft_points));
    Vector#(fft_points, ComplexSample) stage_temp = newVector();
    for(Integer i = 0; i < (valueof(fft_points)/2); i = i+1) begin    
        Integer idx = i * 2;
        let twid = twiddles[stage][i];
        // function Vector#(2, ComplexSample) bfly2(Vector#(2, ComplexSample) t, ComplexSample k);
        let y = bfly2(takeAt(idx, stage_in), twid);

        stage_temp[idx]   = y[0];
        stage_temp[idx+1] = y[1];
    end 

    Vector#(fft_points, ComplexSample) stage_out = newVector();
    for (Integer i = 0; i < valueof(fft_points); i = i+1) begin
        stage_out[i] = stage_temp[permute(i, valueof(fft_points))];
    end
    return stage_out;
endfunction

// module mkCombinationalFFT (FFT#(fft_points)) provisos(Add#(2, a__, fft_points));

//   // Statically generate the twiddle factors table.
//   TwiddleTable#(fft_points) twiddles = genTwiddles();

//   // Define the stage_f function which uses the generated twiddles.
//   function Vector#(fft_points, ComplexSample) stage_f(Bit#(TLog#(TLog#(fft_points))) stage, Vector#(fft_points, ComplexSample) stage_in);
//       return stage_ft(twiddles, stage, stage_in);
//   endfunction

//   FIFO#(Vector#(fft_points, ComplexSample)) inputFIFO  <- mkFIFO(); 
//   FIFO#(Vector#(fft_points, ComplexSample)) outputFIFO <- mkFIFO(); 

//   // This rule performs fft using a big mass of combinational logic.
//   rule comb_fft;

//     Vector#(TAdd#(1, TLog#(fft_points)), Vector#(fft_points, ComplexSample)) stage_data = newVector();
//     stage_data[0] = inputFIFO.first();
//     inputFIFO.deq();

//     for(Integer stage = 0; stage < valueof(TLog#(fft_points)); stage=stage+1) begin
//         stage_data[stage+1] = stage_f(fromInteger(stage), stage_data[stage]);  
//     end

//     outputFIFO.enq(stage_data[valueof(TLog#(fft_points))]);
//   endrule

//   interface Put request;
//     method Action put(Vector#(fft_points, ComplexSample) x);
//         inputFIFO.enq(bitReverse(x));
//     endmethod
//   endinterface

//   interface Get response = toGet(outputFIFO);

// endmodule

// // Problem 2
// module mkLinearFFT (FFT#(fft_points)) provisos(Add#(2, a__, fft_points));
//     // Statically generate the twiddle factors table.
//     TwiddleTable#(fft_points) twiddles = genTwiddles();

//     // ? wrap for what?
//     // Define the stage_f function which uses the generated twiddles.
//     function Vector#(fft_points, ComplexSample) stage_f(Bit#(TLog#(TLog#(fft_points))) stage, Vector#(fft_points, ComplexSample) stage_in);
//         return stage_ft(twiddles, stage, stage_in);
//     endfunction

//     // in and out data
//     FIFO#(Vector#(fft_points, ComplexSample)) inputFIFO  <- mkFIFO(); 
//     FIFO#(Vector#(fft_points, ComplexSample)) outputFIFO <- mkFIFO(); 
//     // stage_data, use Maybe
//     // one stage data: Maybe#(Vector#(fft_points, ComplexSample))
//     // TLog#(fft_points) stages 
//     Vector#(TAdd#(1, TLog#(fft_points)), Reg#(Maybe#(Vector#(fft_points, ComplexSample)))) stage_data <- replicateM(mkReg(tagged Invalid));


//     rule linear_fft;
//         stage_data[0] <= tagged Valid inputFIFO.first();
//         inputFIFO.deq();

//         for(Integer stage = 0; stage < valueof(TLog#(fft_points)); stage=stage+1) begin
//             case (stage_data[stage]) matches
//                 // has data, compute, input next stage
//                 tagged Valid .data: stage_data[stage+1] <= tagged Valid stage_f(fromInteger(stage), data);
//                 // no data, do nothing
//                 tagged Invalid:  stage_data[stage+1] <= tagged Invalid;
//             endcase
//         end

//         // if finish log stages, enqueue to outputFIFO
//         if (isValid(stage_data[valueof(TLog#(fft_points))]) == True) begin
//             outputFIFO.enq(fromMaybe(?, stage_data[valueof(TLog#(fft_points))]));
//         end

//     endrule

//     interface Put request;
//         method Action put(Vector#(fft_points, ComplexSample) x);
//             inputFIFO.enq(bitReverse(x));
//         endmethod
//     endinterface

//     interface Get response = toGet(outputFIFO);

// endmodule

// Problem 3
module mkCircularFFT (FFT#(fft_points)) provisos(Add#(2, a__, fft_points));
    // Statically generate the twiddle factors table.
    TwiddleTable#(fft_points) twiddles = genTwiddles();

    // ? wrap for what?
    // Define the stage_f function which uses the generated twiddles.
    function Vector#(fft_points, ComplexSample) stage_f(Bit#(TLog#(TLog#(fft_points))) stage, Vector#(fft_points, ComplexSample) stage_in);
        return stage_ft(twiddles, stage, stage_in);
    endfunction

    // in and out data
    FIFO#(Vector#(fft_points, ComplexSample)) inputFIFO  <- mkFIFO(); 
    FIFO#(Vector#(fft_points, ComplexSample)) outputFIFO <- mkFIFO(); 
    // stage_data, update every stage
    Reg#(Vector#(fft_points, ComplexSample)) stage_data <- mkRegU();
    // stage, use Maybe
    Reg#(Maybe#(Bit#(TLog#(TLog#(fft_points))))) stage <- mkReg(tagged Invalid);

    Reg#(Bool) first_round <- mkReg(True);  

    rule circular_fft;
        // tmp stage data
        Vector#(fft_points, ComplexSample) tmp=?;

        case (stage) matches
            // not the first stage
            tagged Valid .current_stage: begin
                tmp = stage_f(current_stage, stage_data);
                if (current_stage == fromInteger(valueOf(TLog#(fft_points))-1)) begin
                    // last stage
                    stage <= tagged Invalid;
                    
                end else begin
                    // not last stage
                    stage <= tagged Valid (current_stage + 1);
                end
            end
            // the first stage
            tagged Invalid: begin
                tmp = stage_f(0, inputFIFO.first);
                inputFIFO.deq();
                stage <= tagged Valid 1;


                if (first_round == False) begin
                    outputFIFO.enq(stage_data);
                end
                first_round <= False;
            end
        endcase
        stage_data <= tmp;
    endrule

    interface Put request;
        method Action put(Vector#(fft_points, ComplexSample) x);
            inputFIFO.enq(bitReverse(x));
        endmethod
    endinterface

    interface Get response = toGet(outputFIFO);

endmodule

// Wrapper around The FFT module we actually want to use
module mkFFT (FFT#(fft_points)) provisos(Add#(2, a__, fft_points));
    FFT#(fft_points) fft <- mkCircularFFT();
    //FFT#(fft_points) fft <- mkCombinationalFFT();
    //FFT#(fft_points) fft <- mkLinearFFT();
    interface Put request = fft.request;
    interface Get response = fft.response;
endmodule

// Inverse FFT, based on the mkFFT module.
// ifft[k] = fft[N-k]/N
module mkIFFT (FFT#(fft_points)) provisos(Add#(2, a__, fft_points));

    FFT#(fft_points) fft <- mkFFT();
    FIFO#(Vector#(fft_points, ComplexSample)) outfifo <- mkFIFO();

    Integer n = valueof(fft_points);
    Integer lgn = valueof(TLog#(fft_points));

    function ComplexSample scaledown(ComplexSample x);
        return cmplx(x.rel >> lgn, x.img >> lgn);
    endfunction

    rule inversify (True);
        let x <- fft.response.get();
        Vector#(fft_points, ComplexSample) rx = newVector;

        for (Integer i = 0; i < n; i = i+1) begin
            rx[i] = x[(n - i)%n];
        end
        outfifo.enq(map(scaledown, rx));
    endrule

    interface Put request = fft.request;
    interface Get response = toGet(outfifo);

endmodule
