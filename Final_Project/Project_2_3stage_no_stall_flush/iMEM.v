`timescale 1ns / 1ps

module iMEM(
input reset,
input [7:0] PC_in,
output [31:0] instruction_out
   );
parameter ROM_size = 32;
reg [31:0] ROM [0:ROM_size-1];

integer i;
initial begin
	for(i=0;i!=ROM_size;i=i+1) begin
		ROM[i] = 32'b0;
	end
	$readmemh("../src/darksocv.mem",ROM);
end

// MEM read는 사실 clock이랑 상관 없음.
assign instruction_out = (reset) ? 32'b0 : ROM[PC_in];