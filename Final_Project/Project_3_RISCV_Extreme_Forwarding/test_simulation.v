`timescale 1ns / 1ps

`include "./config.vh"

module tb_simulation;

	// Inputs
`ifndef simulation
	reg 	[ 4:0] key;
	reg	[ 5:0] Switch;
	reg 	[ 3:0] digit;
	reg 	[ 7:0] fnd;
	reg 	[15:0] LED;
`endif
	/////////////////////////////////////
	reg 		 	clk, rst;
	// Instantiate the Unit Under Test (UUT)
	Extreme_RISCV uut (
`ifndef simulation
	key,
	Switch,
	digit,
	fnd,
	LED
`endif
	/////////////////////////////////////
	.clk(clk), .rst(rst)
	);
`ifdef simulation
	initial begin
		rst=1;
		#11 rst=0;
	end    
	initial begin
		clk=0;
		forever #10 clk=~clk;
	end    
`endif      
endmodule

