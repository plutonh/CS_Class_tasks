`timescale 1ns / 1ps

module mux41_conop(
	input [1:0] sel,
	input [3:0] a, 
	input [3:0] b, 
	input [3:0] c, 
	input [3:0] d,
	output reg [3:0] y
	);
	 
	assign y = (sel == 0) ? a : 
		(sel == 1) ? b : 
		(sel == 2) ? c : 
		(sel == 3) ? d : 4'bx;

endmodule