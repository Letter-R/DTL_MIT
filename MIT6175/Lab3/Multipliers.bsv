import Vector :: * ;

// Reference functions that use Bluespec's '*' operator
function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction

function Bit#(TAdd#(n,1)) add_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,1)) add_uint = zeroExtend(a_uint) + zeroExtend(b_uint);
    return pack( add_uint );
endfunction

// arithmetic right shift
// keep sign bit
function Bit#(n) shr_signed( Bit#(n) a, Integer x );
    Int#(n) a_int = unpack(a);
    Int#(n) shr_int = a_int >> x;
    return pack( shr_int );
endfunction


// Multiplication by repeated addition
function Bit#(TAdd#(n,n)) multiply_by_adding( Bit#(n) a, Bit#(n) b );
    // TODO: Implement this function in Exercise 2
    Bit#(n) r1 = 0;
    Bit#(n) r2 = 0;
    for (Integer i=0;i<valueOf(n);i=i+1) begin
        Bit#(n) m=b[i]==1?a:0;
        let sum = add_unsigned(r2,m);
        r1[i] = sum[0];
        r2=truncateLSB(sum);
    end
    return {r2,r1};
endfunction



// Multiplier Interface
interface Multiplier#( numeric type n );
    method Bool start_ready();
    method Action start( Bit#(n) a, Bit#(n) b );
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface



// Folded multiplier by repeated addition
module mkFoldedMultiplier( Multiplier#(n) );
    // You can use these registers or create your own if you want
    Reg#(Bit#(n)) a <- mkRegU();
    Reg#(Bit#(n)) b <- mkRegU();
    Reg#(Bit#(n)) prod <- mkRegU();
    Reg#(Bit#(n)) tp <- mkRegU();
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mulStep( /* guard goes here */ i < fromInteger(valueOf(n)) );
        // TODO: Implement this in Exercise 4
        Bit#(n) m=b[0]==1?a:0;
        let sum = add_unsigned(tp,m);
        Bit#(TSub#(n,1)) tmp =prod[?:1];
        prod <= {sum[0],tmp};
        tp<=truncateLSB(sum);
        i<=i+1;
        b<=b>>1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 4
        return i==fromInteger(valueOf(n)+1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn );
        // TODO: Implement this in Exercise 4
        a<=aIn;
        b<=bIn;
        prod<=0;
        tp<=0;
        i<=0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 4
        return i==fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 4
        i<=i+1;
        return {tp,prod};
    endmethod
endmodule



// Booth Multiplier
module mkBoothMultiplier( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mul_step (i < fromInteger(valueOf(n)));
        // TODO: Implement this in Exercise 6
        Bit#(TAdd#(TAdd#(n,n),1)) tmp=?;
        case (p[1:0])
            2'b01: tmp = p+m_pos;
            2'b10: tmp = p+m_neg;
            2'b00,2'b11: tmp = p;
        endcase
        p<=shr_signed(tmp,1);
        i <= i+1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 6
        return i==fromInteger(valueOf(n)+1);
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 6
        m_pos<={m,0};
        m_neg<={(-m),0};
        p<={0,r,1'b0};
        i<=0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 6
        return i == fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 6
        i<=i+1;
        return truncateLSB(p);
    endmethod
endmodule



// Radix-4 Booth Multiplier
module mkBoothMultiplierRadix4( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)/2+1) );

    rule mul_step( /* guard goes here */  i < fromInteger(valueOf(n)/2) );
        // TODO: Implement this in Exercise 8
        /// 00	    0		00
        // 00	    1		0+
        // 01	    0	    0+
        // 01	    1		+0
        // 10	    0		-0
        // 10	    1		0-
        // 11	    0		0-
        /// 11	    1	    00
        Bit#(TAdd#(TAdd#(n,n),2)) tmp=?;
        case (p[2:0])
            3'b001,3'b010: tmp = p+m_pos;
            3'b011: tmp = p+(m_pos<<1);
            3'b100: tmp = p+(m_neg<<1);
            3'b101,3'b110: tmp = p+m_neg;
            3'b000,3'b111: tmp = p;
        endcase
        p<=shr_signed(tmp,2);
        i <= i+1;

    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 8
        return i == fromInteger(valueOf(n)/2+1);
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 8
        m_pos <= {m[valueOf(n)-1], m, 0};
        m_neg <= {(-m)[valueOf(n)-1], (-m), 0};
        p <= {0, r, 1'b0};
        i <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 8
        return i == fromInteger(valueOf(n)/2);
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 8
        i <= i+1;
        return p[valueOf(n)*2:1];
    endmethod
endmodule

