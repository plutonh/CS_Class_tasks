`timescale 1ns / 1ps
//8.408ns
//forwairdng�� ���� ��.
module Register_File(
	input clk, rst,
	input Ctl_RegWrite_in, EXE_Ctl_MemtoReg_in, EXE_Ctl_RegWrite_in, 
	input [4:0] Rs1, Rs2, EXE_Rd_in, 
	input [4:0] WriteReg_in, 	
	input [31:0] WriteData_in, ALUresult_in, 
	output [31:0] ReadData1_out, ReadData2_out,
	output [1:0] EXE_forwarding
   );
	
	//Register
	parameter reg_size = 32;
	reg [31:0] Reg[0:reg_size-1]; //32bit reg

	//�׻� x0�� Ctl_RegWrite=0�̹Ƿ� Rd�˻� ���ʿ�
	//�񵿱������� �����͸� �ް� �����Ƿ� WB stage�� ������ Write��.
	always@(posedge clk) begin
		if(rst)
			Reg[5'b0] <= 32'b0;
		else if(Ctl_RegWrite_in)
			Reg[WriteReg_in] <= WriteData_in;
	end


	
	assign EXE_forwarding = { ({EXE_Ctl_MemtoReg_in, EXE_Ctl_RegWrite_in}==2'b11 && EXE_Rd_in==Rs2) ? 1'b1:1'b0,
										({EXE_Ctl_MemtoReg_in, EXE_Ctl_RegWrite_in}==2'b11 && EXE_Rd_in==Rs1) ? 1'b1:1'b0 };
	
	assign ReadData1_out = ({EXE_Ctl_MemtoReg_in, EXE_Ctl_RegWrite_in}==2'b01 && EXE_Rd_in==Rs1)? ALUresult_in : 
												(Ctl_RegWrite_in && WriteReg_in==Rs1) ? WriteData_in : Reg[Rs1];
	assign ReadData2_out = ({EXE_Ctl_MemtoReg_in, EXE_Ctl_RegWrite_in}==2'b01 && EXE_Rd_in==Rs2)? ALUresult_in : 
												(Ctl_RegWrite_in && WriteReg_in==Rs2) ? WriteData_in : Reg[Rs2];
endmodule


//4.853ns
//forwarding unit�� IF/ID, ID/EX, EX/MEM REG���� RD���� ���� ���� �ϸ� forwarding unit�� 1cycle �ȿ��� �۵��ϸ� ��.
//
/*
module Forwarding_unit(
	input EXE_Ctl_RegWrite_in, EXE_Ctl_MemtoReg_in, MEM_Ctl_RegWrite_in, clk,
	input [4:0] Rs1_in, Rs2_in, EXE_Rd_in, MEM_Rd_in,
	output reg [1:0] ForwardA_out, ForwardB_out
   );
		 
	reg [1:0] ForwardA, ForwardB;
	
	
	//Forward[0]���� forward������ ���, Forward[1]�� �� Forward�ϳ��� ���.
	always @(*) begin
		if(ID_EX_Rd_in == Rs1_in) 			ForwardA = 2'b10;
		else if(EX_MEM_Rd_in == Rs1_in) 	ForwardA = 2'b01;
		else 										ForwardA = 2'b00;
	end
	
	always @(*) begin
		if(ID_EX_Rd_in == Rs2_in)			ForwardB = 2'b10;
		else if(EX_MEM_Rd_in == Rs2_in)	ForwardB = 2'b01;
		else										ForwardB = 2'b00;
	end
	

endmodule
*/