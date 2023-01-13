`timescale 1ns / 1ps

module STAGE3(
	input rst, clk,
	input Ctl_MemtoReg_in, Ctl_MemWrite_in,
	input [31:0] Write_Data_in, ALUresult_in, 
	//비동기 출력
		
	output [31:0] WriteData_out, LoadData
    );
//5.971ns
	 

wire [31:0] ALUresult_out;
Memory MEM(
.clk(clk),
.reset(rst), 
.Ctl_MemWrite_in(Ctl_MemWrite_in), 	//비동기
.Write_Data_in(Write_Data_in), 		//비동기
.ALUresult_in(ALUresult_in), 			//비동기
.LoadData(LoadData), 
.ALUresult_out(ALUresult_out)
   );


WB WriteBack(
.Ctl_MemtoReg_in(Ctl_MemtoReg_in), 
.LoadData_in(LoadData), 
.ALUresult_in(ALUresult_out),
.WriteData_out(WriteData_out)
);



endmodule
