`timescale 1ns / 1ps

module STAGE3(
	input rst, clk,
	input Ctl_MemtoReg_in, Ctl_MemWrite_in,
	input [31:0] Write_Data_in, ALUresult_in, 
	//�񵿱� ���
		
	output [31:0] WriteData_out, LoadData
    );
//6.097ns
	 

wire [31:0] ALUresult_out;
Memory MEM(
.clk(clk),
.reset(rst), 
.Ctl_MemWrite_in(Ctl_MemWrite_in), 	//�񵿱�
.Write_Data_in(Write_Data_in), 		//�񵿱�
.ALUresult_in(ALUresult_in), 			//�񵿱�
.LoadData(LoadData),
.ALUresult_out(ALUresult_out)
   );

//WB stage
//�񵿱� ��ȣ������ '������' WB stage�� ���۶� reg�� write�ȴ�.
assign WriteData_out = (Ctl_MemtoReg_in)? LoadData : ALUresult_out;


endmodule
