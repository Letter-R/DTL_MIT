
import Complex::*;
import FixedPoint::*;
import Reg6375::*;

export AudioProcessorTypes::*;
export Reg6375::*;

typedef Int#(16) Sample;

interface AudioProcessor;
    method Action putSampleInput(Sample in);
    method ActionValue#(Sample) getSampleOutput();
endinterface


typedef Complex#(FixedPoint#(16, 16)) ComplexSample;

// Turn a real Sample into a ComplexSample.
function ComplexSample tocmplx(Sample x);
    return cmplx(fromInt(x), 0);
endfunction

// Extract the real component from complex.
function Sample frcmplx(ComplexSample x);
    return unpack(truncate(x.rel.i));
endfunction


typedef 8 N_VALUE;
typedef 2 S_VALUE;
typedef 2 FACTOR_VALUE;
typedef 16 PSIZE_VALUE;

// typedef 8 FFT_POINTS;
// typedef TLog#(FFT_POINTS) FFT_LOG_POINTS;

// Use N = 8, S = 2,
// pitch shifting factor= 2, 
// psize = 16 bits for the phase values.