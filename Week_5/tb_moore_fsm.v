`timescale 1ns / 1ps

module tb_moore_fsm;
//Input
reg clk, rst, bypass;
//Output
wire [1:0] out;

moore_fsm uut(
	.clk(clk),
	.rst(rst),
	.bypass(bypass),
	.out(out)
    );

initial begin
	rst=1;
	#15 rst=0;
	#25 rst=1;
end

initial begin
	clk=0;
	forever
	#10 clk = ~clk;
end

initial begin
	bypass=0;
	#100 bypass=1;
	#100 bypass=0;
	#100 $stop;
end
endmodule