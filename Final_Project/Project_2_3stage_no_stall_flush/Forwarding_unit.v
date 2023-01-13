`timescale 1ns / 1ps
//8.408ns
//(Ctl_RegWrite_in && WriteReg_in==Rs1) ? WriteData : Reg[Rs1]
module Register_File(
	input clk, rst,
	input Ctl_RegWrite_in, //from WB unit
	input [4:0] Rs1, Rs2, 
	input [4:0] WriteReg_in, //동기 신호임.
	input [31:0] WriteData_in, //비동기 신호임
	output [31:0] ReadData1_out, ReadData2_out
   );
	
	//Register
	parameter reg_size = 32;
	reg [31:0] Reg[0:reg_size-1]; //32bit reg

	always@(posedge clk) begin
		if(rst) Reg[5'b0] <= 32'b0;
		else if(Ctl_RegWrite_in && WriteReg_in!=0)
			Reg[WriteReg_in] <= WriteData_in; //이전 사이클에 지속적으로 전달받는 값.
	end

	assign ReadData1_out = (Rs1==5'b0)? 32'b0:(Ctl_RegWrite_in && WriteReg_in==Rs1) ? WriteData_in : Reg[Rs1];
	assign ReadData2_out = (Rs2==5'b0)? 32'b0:(Ctl_RegWrite_in && WriteReg_in==Rs2) ? WriteData_in : Reg[Rs2];
endmodule
