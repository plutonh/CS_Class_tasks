`timescale 1ns / 1ps
module ALU_RCA_32bit(
	input [31:0] a_in,
	input [31:0] b_in,
	input [3:0] op,
	output [31:0] result,
	output zero,
	output overflow
	);
	wire [30:0] co;
	wire set;
		 
	ALU_1bit u0				(a_in[0], 	b_in[0], 	op[2], 	op[3], op[2], set,  op[1:0], result[0], 	co[0]);
	ALU_1bit u1				(a_in[1], 	b_in[1], 	co[0], 	op[3], op[2], 1'b0, op[1:0], result[1], 	co[1]);
	ALU_1bit u2				(a_in[2], 	b_in[2], 	co[1], 	op[3], op[2], 1'b0, op[1:0], result[2], 	co[2]);
	ALU_1bit u3				(a_in[3], 	b_in[3], 	co[2], 	op[3], op[2], 1'b0, op[1:0], result[3], 	co[3]);
	ALU_1bit u4				(a_in[4], 	b_in[4], 	co[3], 	op[3], op[2], 1'b0, op[1:0], result[4], 	co[4]);
	ALU_1bit u5				(a_in[5], 	b_in[5], 	co[4], 	op[3], op[2], 1'b0, op[1:0], result[5], 	co[5]);
	ALU_1bit u6				(a_in[6],	b_in[6], 	co[5], 	op[3], op[2], 1'b0, op[1:0], result[6], 	co[6]);
	ALU_1bit u7				(a_in[7],	b_in[7], 	co[6], 	op[3], op[2], 1'b0, op[1:0], result[7], 	co[7]);
	ALU_1bit u8				(a_in[8], 	b_in[8], 	co[7], 	op[3], op[2], 1'b0, op[1:0], result[8], 	co[8]);
	ALU_1bit u9				(a_in[9], 	b_in[9], 	co[8], 	op[3], op[2], 1'b0, op[1:0], result[9], 	co[9]);
	ALU_1bit u10			(a_in[10], 	b_in[10], 	co[9], 	op[3], op[2], 1'b0, op[1:0], result[10], 	co[10]);
	ALU_1bit u11			(a_in[11], 	b_in[11], 	co[10], 	op[3], op[2], 1'b0, op[1:0], result[11], 	co[11]);
	ALU_1bit u12			(a_in[12], 	b_in[12], 	co[11], 	op[3], op[2], 1'b0, op[1:0], result[12], 	co[12]);
	ALU_1bit u13			(a_in[13], 	b_in[13], 	co[12], 	op[3], op[2], 1'b0, op[1:0], result[13], 	co[13]);
	ALU_1bit u14			(a_in[14], 	b_in[14], 	co[13], 	op[3], op[2], 1'b0, op[1:0], result[14], 	co[14]);
	ALU_1bit u15			(a_in[15], 	b_in[15], 	co[14], 	op[3], op[2], 1'b0, op[1:0], result[15], 	co[15]);
	ALU_1bit u16			(a_in[16], 	b_in[16], 	co[15], 	op[3], op[2], 1'b0, op[1:0], result[16], 	co[16]);
	ALU_1bit u17			(a_in[17], 	b_in[17], 	co[16], 	op[3], op[2], 1'b0, op[1:0], result[17], 	co[17]);
	ALU_1bit u18			(a_in[18], 	b_in[18], 	co[17], 	op[3], op[2], 1'b0, op[1:0], result[18], 	co[18]);
	ALU_1bit u19			(a_in[19], 	b_in[19], 	co[18], 	op[3], op[2], 1'b0, op[1:0], result[19], 	co[19]);
	ALU_1bit u20			(a_in[20], 	b_in[20], 	co[19], 	op[3], op[2], 1'b0, op[1:0], result[20], 	co[20]);
	ALU_1bit u21			(a_in[21], 	b_in[21], 	co[20], 	op[3], op[2], 1'b0, op[1:0], result[21], 	co[21]);
	ALU_1bit u22			(a_in[22], 	b_in[22], 	co[21], 	op[3], op[2], 1'b0, op[1:0], result[22], 	co[22]);
	ALU_1bit u23			(a_in[23], 	b_in[23],	co[22], 	op[3], op[2], 1'b0, op[1:0], result[23], 	co[23]);
	ALU_1bit u24			(a_in[24], 	b_in[24], 	co[23], 	op[3], op[2], 1'b0, op[1:0], result[24], 	co[24]);
	ALU_1bit u25			(a_in[25], 	b_in[25], 	co[24], 	op[3], op[2], 1'b0, op[1:0], result[25], 	co[25]);
	ALU_1bit u26			(a_in[26], 	b_in[26], 	co[25], 	op[3], op[2], 1'b0, op[1:0], result[26], 	co[26]);
	ALU_1bit u27			(a_in[27], 	b_in[27], 	co[26], 	op[3], op[2], 1'b0, op[1:0], result[27], 	co[27]);
	ALU_1bit u28			(a_in[28], 	b_in[28], 	co[27], 	op[3], op[2], 1'b0, op[1:0], result[28], 	co[28]);
	ALU_1bit u29			(a_in[29], 	b_in[29], 	co[28], 	op[3], op[2], 1'b0, op[1:0], result[29], 	co[29]);
	ALU_1bit u30			(a_in[30], 	b_in[30], 	co[29], 	op[3], op[2], 1'b0, op[1:0], result[30], 	co[30]);
	ALU_1bit_overflow u31(a_in[31], 	b_in[31], 	co[30], 	op[3], op[2], 1'b0, op[1:0], result[31], 	set, overflow);
		
	assign zero = ~|result;
		
endmodule

module ALU_1bit(
	input a_in,
	input b_in,
	input carry_in,
	input invert_a,
	input invert_b,
	input less,
	input [1:0] op,
	output result,
	output carry_out
	);
	wire a_out, b_out;
	wire and_out, or_out, sum;
			
	fulladder_1bit fu(a_out, b_out, carry_in, sum, carry_out);
	mux_operation m2(op, and_out, or_out, sum, less, result);
		
	and(and_out, a_out, b_out);
	or(or_out, a_out, b_out);
	xor(a_out, a_in, invert_a);
	xor(b_out, b_in, invert_b);
		
endmodule
	
module ALU_1bit_overflow(
	input ai, 	// a_in			
	input bi, 	// b_in
	input ci, 	// carry_in
	input aiv, 	// a_invert
	input biv, 	// b_invert
	input less,
	input [1:0] op,
	output re, 	// result
	output set,	// less than
	output of 	// overflow
	);
	wire ao, bo, co;
	wire o0,o1,o2;
		
	fulladder_1bit fu(ao, bo, ci, o2, co);
		
	mux_operation m2(op, o0, o1, o2, less, re);
		
	and(o0, ao, bo);
	or(o1, ao, bo);
	xor(ao, ai, aiv);
	xor(bo, bi, biv);
	assign set = of^o2;	//XOR(overflow, result of sum)
	assign of  = ci^co;	//XOR(Cin, Cout)
		
endmodule

module mux_operation(op, a, b, c, d, y);
	input [1:0] op;
	input a, b, c, d;
	output reg y;
		
	always @(*) begin
		case(op)
			0: y = a;
			1: y = b;
			2: y = c;
			3: y = d;
			default: y = 1'bx;
		endcase
	end 

endmodule
	
	
module fulladder_1bit(
	input a,
	input b,
	input ci,
	output s,
	output co
	);
	wire s1,c1,c2;
	half_adder ha1(a,b,s1,c1);
	half_adder ha2(ci,s1,s,c2);
	or(co,c1,c2);
		
endmodule

module half_adder(x,y,s,c);
	input x,y;
	output s,c;
	xor(s,x,y);
	and(c,x,y);
		
endmodule