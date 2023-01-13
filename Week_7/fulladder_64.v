`timescale 1ns / 1ps

module fulladder_64bit(
	input [63:0] a,
	input [63:0] b,
	input ci,
	output [63:0] sum,
	output Cout
    );
	wire cout;


	fulladder_32bit fa0(.a(a[31:0]), .b(b[31:0]), .ci(ci), .sum(sum[31:0]), .Cout(cout));
	fulladder_32bit fa1(.a(a[63:32]), .b(b[63:32]), .ci(cout), .sum(sum[63:32]), .Cout(Cout));
endmodule



module fulladder_32bit(
	input [31:0] a,
	input [31:0] b,
	input ci,
	output [31:0] sum,
	output Cout
    );
	wire [6:0]cout;


	fulladder_4bit fa0(.a(a[3:0]), .b(b[3:0]), .ci(ci), .sum(sum[3:0]), .cout(cout[0]));
	fulladder_4bit fa1(.a(a[7:4]), .b(b[7:4]), .ci(cout[0]), .sum(sum[7:4]), .cout(cout[1]));
	fulladder_4bit fa2(.a(a[11:8]), .b(b[11:8]), .ci(cout[1]), .sum(sum[11:8]), .cout(cout[2]));
	fulladder_4bit fa3(.a(a[15:12]), .b(b[15:12]), .ci(cout[2]), .sum(sum[15:12]), .cout(cout[3]));
	fulladder_4bit fa4(.a(a[19:16]), .b(b[19:16]), .ci(cout[3]), .sum(sum[19:16]), .cout(cout[4]));
	fulladder_4bit fa5(.a(a[23:20]), .b(b[23:20]), .ci(cout[4]), .sum(sum[23:20]), .cout(cout[5]));
	fulladder_4bit fa6(.a(a[27:24]), .b(b[27:24]), .ci(cout[5]), .sum(sum[27:24]), .cout(cout[6]));
	fulladder_4bit fa7(.a(a[31:28]), .b(b[31:28]), .ci(cout[6]), .sum(sum[31:28]), .cout(Cout));
endmodule



module fulladder_4bit(
	input [3:0] a,
	input [3:0] b,
	input ci,
	output [3:0] sum,
	output cout
    );
	wire c1, c2, c3;


	fulladder_1bit fa1(.a(a[0]), .b(b[0]), .ci(ci), .s(sum[0]), .co(c1));
	fulladder_1bit fa2(.a(a[1]), .b(b[1]), .ci(c1), .s(sum[1]), .co(c2));
	fulladder_1bit fa3(.a(a[2]), .b(b[2]), .ci(c2), .s(sum[2]), .co(c3));
	fulladder_1bit fa4(.a(a[3]), .b(b[3]), .ci(c3), .s(sum[3]), .co(cout));

endmodule


module fulladder_1bit(
	input a, b, ci,
	output s, co
	);
	wire s1, c1, c2;
	
	half_adder ha1(.a(a), .b(b), .s(s1), .c(c1));
	half_adder ha2(.a(ci), .b(s1), .s(s), .c(c2));
	or carry(co, c1, c2);
endmodule


module half_adder(
	input a, b,
	output s, c
	);
	
	xor sum(s,a,b);
	and carry(c,a,b);

endmodule