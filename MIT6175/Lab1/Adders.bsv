import Multiplexer::*;

function Bit#(1) fa_sum(Bit#(1) a, Bit#(1) b, Bit#(1) c);
    return a ^ b ^ c;
endfunction

function Bit#(1) fa_carry(Bit#(1) a, Bit#(1) b, Bit#(1) c);
    return (a&b) | (a&c) | (b&c);
endfunction

function Bit#(TAdd#(n,1)) addN(Bit#(n) a, Bit#(n) b, Bit#(1) c0);
    Bit#(n) s;
    Bit#(1) c = c0;
    for(Integer i = 0; i < valueOf(n); i = i + 1)
    begin
        s[i] = fa_sum(a[i], b[i], c);
        c = fa_carry(a[i], b[i], c);
    end
    return {c,s};
endfunction
/*
function Bit#(5) add4(Bit#(4) a, Bit#(4) b, Bit#(1) c0);
    return addN(a,b,c0);
endfunction
*/
interface Adder8;
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b, Bit#(1) c_in);
endinterface

module mkRCAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
        let low = add4(a[3:0], b[3:0], c_in);
        let high = add4(a[7:4], b[7:4], low[4]);
        return { high, low[3:0] };
    endmethod
endmodule
/*
module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b,Bit#(1) c_in);
        let low = add4(a[3:0], b[3:0], c_in);
        let high0 = add4(a[7:4], b[7:4], 1'b0);
        let high1 = add4(a[7:4], b[7:4], 1'b1);
        let high = multiplexer5(low[4], high0, high1);
        return { high, low[3:0] };
    endmethod
endmodule
*/

// exercise 4
function Bit#(5) add4(Bit#(4) a,Bit#(4) b,Bit#(1) c_in);
    Bit#(4) sum;
    Bit#(5) carry=?;carry[0]=c_in;
    for (Integer i=0;i<4;i=i+1) begin
        sum[i] = fa_sum(a[i],b[i],carry[i]);
        carry[i+1]=fa_carry(a[i],b[i],carry[i]);
    end
    return {carry[4],sum};
endfunction

// exercise 5
/*
real    0m0.4s

module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a,Bit#(8) b, Bit#(1) c_in);
        let low=add4(a[3:0],b[3:0],c_in);
        let high1=add4(a[7:4],b[7:4],'b1);
        let high0=add4(a[7:4],b[7:4],'b0);
        let high = multiplexer_n(low[4],high0,high1);
        return {high,low[3:0]};
    endmethod
endmodule
*/
// real    0m0.16s
module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) sum(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
        Bit#(5) low=?;Bit#(5) high1=?;Bit#(5) high0=?;
        action
            low = add4(a[3:0], b[3:0], c_in);
        endaction

        action
            high1 = add4(a[7:4], b[7:4], 'b1);
        endaction

        action
            high0 = add4(a[7:4], b[7:4], 'b0);
        endaction

        let high = multiplexer_n(low[4], high0, high1);

        // 返回结果
        return {high, low[3:0]};
    endmethod
endmodule

