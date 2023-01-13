`timescale 1ns / 1ps

module PC(
input clk, reset,
input PCWrite,
input [31:0] PC_in,
output reg [31:0] PC_out
);
always @(posedge clk) begin
	if(reset) PC_out <= 0;
	else if(PCWrite) PC_out <= PC_in;

end
endmodule
