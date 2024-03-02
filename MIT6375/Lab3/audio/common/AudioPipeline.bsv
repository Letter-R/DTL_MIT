
import ClientServer::*;
import GetPut::*;
import Vector::*;
import FixedPoint :: *;

import AudioProcessorTypes::*;
import FilterCoefficients::*;
import Chunker::*;
import FFT::*;
import FIRFilter::*;
import Splitter::*;
import MP_Complex::*;
import OverSampler:: *;
import Overlayer::*;
import Cordic:: *;
import Complex::*;
import PitchAdjust::*;

module mkAudioPipeline(AudioProcessor);
    // interface AudioProcessor;
    //     method Action putSampleInput(Sample in);
    //     method ActionValue#(Sample) getSampleOutput();
    // endinterface    
    AudioProcessor fir <- mkFIRFilter(c);
    // typedef Server#(t, Vector#(n, t)) Chunker#(numeric type n, type t);
    Chunker#(S_VALUE, Sample) chunker <- mkChunker();

    // typedef Server#(
    //     Vector#(s, t),
    //     Vector#(n, t)
    // ) OverSampler#(numeric type s, numeric type n, type t);
    OverSampler#(S_VALUE, N_VALUE, Sample) oversampler <- mkOverSampler(replicate(0));

    // typedef Server#(
    //     Vector#(fft_points, Complex#(cmplxd)),
    //     Vector#(fft_points, Complex#(cmplxd))
    // ) FFT#(numeric type fft_points, type cmplxd);
    FFT#(N_VALUE, FixedPoint#(16, 16)) fft <- mkFFT();

    // typedef Server#(
    //     Vector#(nvalue, Complex#(FixedPoint#(16, 16))),
    //     Vector#(nvalue, ComplexMP#(isize, fsize, psize))
    // ) ToMP#(numeric type nvalue, numeric type isize, numeric type fsize, numeric type psize);
    ToMP#(N_VALUE, 16, 16, PSIZE_VALUE) tomp <- mkToMP();

    // typedef Server#(
    //     Vector#(nbins, ComplexMP#(isize, fsize, psize)),
    //     Vector#(nbins, ComplexMP#(isize, fsize, psize))
    // ) PitchAdjust#(numeric type nbins, numeric type isize, numeric type fsize, numeric type psize);
    PitchAdjust#(N_VALUE, 16, 16, PSIZE_VALUE) pitchadjust <- mkPitchAdjust(valueOf(S_VALUE), 2);
    
    // typedef Server#(
    //     Vector#(nvalue, ComplexMP#(isize, fsize, psize)),
    //     Vector#(nvalue, Complex#(FixedPoint#(16, 16)))
    // ) FromMP#(numeric type nvalue, numeric type isize, numeric type fsize, numeric type psize);
    FromMP#(N_VALUE, 16, 16, PSIZE_VALUE) frommp <- mkFromMP();

    // typedef Server#(
    //     Vector#(fft_points, Complex#(cmplxd)),
    //     Vector#(fft_points, Complex#(cmplxd))
    // ) FFT#(numeric type fft_points, type cmplxd);
    FFT#(N_VALUE, FixedPoint#(16, 16)) ifft <- mkIFFT();

    // typedef Server#(
    //     Vector#(n, t),
    //     Vector#(s, t)
    // ) Overlayer#(numeric type n, numeric type s, type t);
    Overlayer#(N_VALUE,S_VALUE,Sample) overlayer <- mkOverlayer(replicate(0));

    // typedef Server#(Vector#(n, t), t) Splitter#(numeric type n, type t);
    Splitter#(S_VALUE, Sample) splitter <- mkSplitter();




    rule fir_to_chunker (True);
        let x <- fir.getSampleOutput();
        chunker.request.put(x);
    endrule

    rule chunker_to_oversampler (True);
        let x<- chunker.response.get();
        oversampler.request.put(x);
    endrule

    rule oversampler_to_fft (True);
        Vector#(N_VALUE, Sample) x <- oversampler.response.get();
        Vector#(N_VALUE, Complex#(FixedPoint#(16, 16))) y;
        for (Integer i=0; i<valueOf(N_VALUE); i=i+1) begin
            y[i] = tocmplx(x[i]);
        end
        fft.request.put(y);
    endrule

    rule fft_to_tomp (True);
        let x <- fft.response.get();
        tomp.request.put(x);
    endrule

    rule tomp_to_pitchadjust (True);
        let x <- tomp.response.get();
        pitchadjust.request.put(x);
    endrule

    rule pitchadjust_to_frommp (True);
        let x <- pitchadjust.response.get();
        frommp.request.put(x);
    endrule

    rule frommp_to_ifft (True);
        let x <- frommp.response.get();
        ifft.request.put(x);
    endrule

    rule ifft_to_overlayer (True);
        Vector#(N_VALUE, ComplexSample) x <- ifft.response.get();
        Vector#(N_VALUE, Sample) y;
        for (Integer i=0; i<valueOf(N_VALUE); i=i+1) begin
            y[i] = frcmplx(x[i]);
        end
        overlayer.request.put(y);
    endrule

    rule overlayer_to_splitter (True);
        let x <- overlayer.response.get();
        splitter.request.put(x);
    endrule
    
    method Action putSampleInput(Sample x);
        fir.putSampleInput(x);
    endmethod

    method ActionValue#(Sample) getSampleOutput();
        let x <- splitter.response.get();
        return x;
    endmethod

endmodule

