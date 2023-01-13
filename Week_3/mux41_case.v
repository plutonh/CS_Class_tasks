`timescale 1ns / 1ps

module mux41_case(sel,a,b,c,d, y);
	input [1:0] sel;
	input [3:0] a, b, c, d;
	output reg [3:0] y;
	
	 
	 always @(*) begin
		case(sel)
			0: y = a;
			1: y = b;
			2: y = c;
			3: y = d;
			default : y = 4'bx;
		endcase
	end
endmodule