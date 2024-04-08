import Types::*;
import ProcTypes::*;
import RegFile::*;
import Vector::*;

interface Bht#(numeric type indexSize);
    method Addr ppcDP(Addr pc, Addr targetPC);
    method Action update(Addr pc, Bool taken);
endinterface

typedef Bit#(indexSize) BhtIndex#(numeric type indexSize);

// BHT#(16)
module mkBht(Bht#(indexSize)) provisos( Add#(indexSize,a__,32));
    // 2^16 Reg
    Vector#(TExp#(indexSize), Reg#(Bit#(2))) bhtArr <- replicateM(mkReg(2'b11));
    // Bit#(16) [17:2]
    function BhtIndex#(indexSize) getBhtIndex(Addr pc) = truncate(pc >> 2);
    function Addr computeTarget(Addr pc, Addr targetPC, Bool taken) = taken ? targetPC : pc + 4;  
    function Bool extractDir(Bit#(2) arr) = (arr >> 1) == 1;
    function Bit#(2) getBhtEntry(BhtIndex#(indexSize) index) = bhtArr[index];
    function Bit#(2) newDpBits(Bit#(2) dpBits, Bool taken);  
        if (dpBits == 2'b11 && taken == True) begin
            return dpBits;
        end else if (dpBits == 2'b00 && taken == False) begin
            return dpBits;
        end else if (taken == True) begin
            return dpBits + 1;
        end else begin
            return dpBits - 1;
        end
    endfunction
    
    method Addr ppcDP(Addr pc, Addr targetPC);
        BhtIndex#(indexSize) index = getBhtIndex(pc);
        let direction =  extractDir(bhtArr[index]);
        return computeTarget(pc, targetPC, direction); 
    endmethod
    
    method Action update(Addr pc, Bool taken);
        BhtIndex#(indexSize) index = getBhtIndex(pc);
        let dpBits = getBhtEntry(index);
        let tmp = newDpBits(dpBits,taken); 
        bhtArr[index] <= tmp;
    endmethod
endmodule


