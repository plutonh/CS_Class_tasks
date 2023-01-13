module fulladder_4bit(
input [3:0] a,
input [3:0] b,
output [3:0] sum,
output cout
);
wire c1, c2, c3;

fulladder_1bit fa1(.a(a[0]), .b(b[0]), .ci(0), .s(sum[0]), .co(c1));
fulladder_1bit fa2(.a(a[1]), .b(b[1]), .ci(c1), .s(sum[1]), .co(c2));
fulladder_1bit fa3(.a(a[2]), .b(b[2]), .ci(c2), .s(sum[2]), .co(c3));
fulladder_1bit fa4(.a(a[3]), .b(b[3]), .ci(c3), .s(sum[3]), .co(cout));
endmodule
module fulladder_1bit(
input a,
input b,
input ci,
output s,
output co
);
wire s1, c1, c2;

half_adder hal(.a(a),.b(b), .s(s1), .c(c1));
half_adder ha2(.a(ci),.b(s1), .s(s), .c(c2));
or(co, c1, c2);

endmodule

module half_adder(
input a,
input b,
output s,
output c
);

xor(s, a, b);
and(c, a, b);

endmodule