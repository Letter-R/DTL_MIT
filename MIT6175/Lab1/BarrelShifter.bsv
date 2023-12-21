import Multiplexer::*;

function Bit#(32) shiftRightPow2(Bit#(1) en, Bit#(32) unshifted, Integer power);
    Integer distance = 2**power;
    Bit#(32) shifted = 0;
    if(en == 0) begin
        return unshifted;
    end else begin
        for(Integer i = 0; i < 32; i = i + 1) begin
            if(i + distance < 32) begin
                shifted[i] = unshifted[i + distance];
            end
        end
        return shifted;
    end
endfunction

// exxrcise 6
/*
//time make bs 0.40-0.42ms
function Bit#(32) barrelShifterRight(Bit#(32) in, Bit#(5) shiftBy);
    Bit#(32) unshifted=in;
    for (Integer i=4;i>=0;i=i-1) begin
        
        Bit#(32) shifted = 0;
        Integer j=2**i;
        for(Integer k=0; k < 32 ; k=k+1) begin
            if(k<=31-j) begin
                shifted[k]=unshifted[j+k];
            end else begin
                shifted[k]=0;
            end
        end 


        unshifted=multiplexer_n(shiftBy[i], unshifted, shifted);
    end
    return unshifted;
endfunction
*/
/*
// error at Bit#(32) shifted={tmp, unshifted[31:j]};
// This type resulted from:
//      The proviso Add#(a__, b__, 32) introduced in or at
//      Bit#(32) shifted={tmp, unshifted[31:j]};
function Bit#(32) barrelShifterRight(Bit#(32) in, Bit#(5) shiftBy);
    Bit#(32) unshifted=in;
    for (Integer i=4;i>=0;i=i-1) begin
        Bit#(5) j=0;j[i]=1;
        Bit#(j) tmp=0;
        Bit#(32) shifted={tmp, unshifted[31:j]};
        unshifted=multiplexer_n(shiftBy[i], unshifted, shifted);
    end
    return unshifted;
endfunction
*/
// time make bs 0.40-0.42ms
function Bit#(32) barrelShifterRight(Bit#(32) in, Bit#(5) shiftBy);
    Bit#(32) unshifted=in;
    for (Integer i=4;i>=0;i=i-1) begin
        Bit#(5) j=0;j[i]=1;
        Bit#(32) shifted = unshifted[31:j];
        unshifted=multiplexer_n(shiftBy[i], unshifted, shifted);
    end
    return unshifted;
endfunction
