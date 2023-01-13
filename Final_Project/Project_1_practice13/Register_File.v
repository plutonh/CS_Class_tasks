`timescale 1ns / 1ps

module Register_File(
	input Ctl_RegWrite_in,
	input [4:0] Rs1, Rs2, Rd,
	input [31:0] WriteData,
	output [31:0] ReadData1, ReadData2
    );
	 
parameter reg_size = 32;
reg [31:0] Reg[0:reg_size-1]; //32bit reg
integer i;
always@(posedge clk) begin
	if(reset) begin
		Reg[0] <= 0;
	end
	else if(Ctl_RegWrite_in && WriteReg!=0)
		Reg[Rd] <= WriteData;
end

assign ReadData1 = Reg[Rs1];
assign ReadData2 = Reg[Rs2];


endmodule


