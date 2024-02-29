

import ClientServer::*;
import FIFO::*;
import GetPut::*;

import Complex::*;
import FixedPoint::*;
import Vector::*;
import ComplexMP::*;

import AudioProcessorTypes::*;
import Cordic::*;


typedef Server#(
    Vector#(nvalue, Complex#(FixedPoint#(isize, fsize))),
    Vector#(nvalue, ComplexMP#(isize, fsize, psize))
) ToMP#(numeric type nvalue, numeric type isize, numeric type fsize, numeric type psize);


module mkToMP(ToMP#(nvalue, isize, fsize, psize) ifc) provisos(Min#(TAdd#(isize, fsize), 2, 2),Min#(isize, 1, 1));
    FIFO#(Vector#(nvalue, Complex#(FixedPoint#(isize, fsize)))) inFIFO <- mkFIFO();
    FIFO#(Vector#(nvalue, ComplexMP#(isize, fsize, psize))) outFIFO <- mkFIFO();

    // Server#(Complex#(FixedPoint#(isize, fsize)),ComplexMP#(isize, fsize, psize))
    ToMagnitudePhase#(isize, fsize, psize) tomp <- mkCordicToMagnitudePhase();

    // Reg#(Bit#(TLog#(nvalue))) i_enq <- mkReg(0);
    Reg#(Bit#(TLog#(nvalue))) deq_i <- mkReg(0);
    Reg#(Vector#(nvalue, ComplexMP#(isize, fsize, psize))) deq_vec <- mkReg(replicate(cmplxmp(0, tophase(0))));

    rule enq;
        let indata = inFIFO.first();
        inFIFO.deq();
        for (Integer i=0; i<valueof(nvalue); i=i+1) begin
            let complex_ = indata[i];
            tomp.request.put(complex_);
        end
    endrule

    rule deq;
        let mp = tomp.response.get();
        if (deq_i == fromInteger(valueof(nvalue)-1)) begin
            deq_i <= 0;
            Vector#(nvalue, ComplexMP#(isize, fsize, psize)) tmp = deq_vec;
            tmp[deq_i] = mp;
            outFIFO.enq(tmp);
        end else begin
            deq_i <= deq_i+1;
            deq_vec[deq_i] <= mp;
        end
    endrule


    interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule


typedef Server#(
    Vector#(nvalue, ComplexMP#(isize, fsize, psize)),
    Vector#(nvalue, Complex#(FixedPoint#(isize, fsize)))
) FromMP#(numeric type nvalue, numeric type isize, numeric type fsize, numeric type psize);

module mkFromMP(FromMP#(nvalue, isize, fsize, psize) ifc);




    interface Put request = toPut(inFIFO);
	interface Get response = toGet(outFIFO);
endmodule