function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~a;
endfunction

/////////////////////////////////////////////////////////////////////

// exercise 1
function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    return or1(and1(a, not1(sel)),and1(b,sel));
endfunction

// exercise 2
function Bit#(5) and5(Bit#(5) a, Bit#(5) b); Bit#(5) aggregate;
    for(Integer i = 0; i < 5; i = i + 1) begin
        aggregate[i] = and1(a[i], b[i]);
    end
    return aggregate;
endfunction

// in Adders.bsv, there is
// let high = multiplexer5(low[4], high0, high1);
/*
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);Bit#(5) aggregate;
    for (Integer i = 0; i < 5; i = i + 1) begin
        aggregate[i] = multiplexer1(sel, a[i], b[i]);
    end
    return aggregate;
endfunction
*/

// exercise 3
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    return multiplexer_n(sel,a,b);
endfunction

function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) aggregate;
    for (Integer i = 0; i < valueOf(n); i = i + 1) 
    begin
        aggregate[i] = multiplexer1(sel, a[i], b[i]);
    end
    return aggregate;
endfunction