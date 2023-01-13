`timescale 1ns / 1ps

module InFetch(
input clk, reset,
input PCSrc, stall, 
input [31:0] PC_branch_in,	//branch target address from MEM stage
output reg [31:0] Instruction_out,
output reg [31:0] PC_out	//IF/ID reg의 PC reg
   );
reg  [31:0] PC;
wire [31:0] instruction;
wire [31:0] PC_Next = (PCSrc) ? PC_branch_in : PC + 4;

always @(posedge clk) begin
	if (reset) PC <=0;
	else if (~stall) PC <= PC_Next;
end


iMEM B2_iMEM(
.reset(reset),
.PC_in(PC),
.instruction_out(instruction)
);


//IF/ID reg write when not stall
always @(posedge clk) begin
	if (reset) begin
		PC_out <= 0;
		Instruction_out <= 0;
	end
	else if (~stall) begin
		PC_out <= PC;
		Instruction_out <= instruction;
	end
end
endmodule