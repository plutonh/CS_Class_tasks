`timescale 1ns / 1ps
`include "./config.vh"

module Extreme_RISCV(	
`ifndef simulation
	input 	[ 4:0] key,
	input	 	[ 5:0] Switch,
	output 	[ 3:0] digit,
	output 	[ 7:0] fnd,
	output 	[15:0] LED,
`endif
	/////////////////////////////////////
	input 		  clk, rst
    );
//확인 결과 최대 걸리는 시간이 18.066ns이다.
wire Stage2_Ctl_ALUSrc, Stage2_Ctl_MemtoReg, Stage2_Ctl_RegWrite, Stage2_Ctl_MemWrite, Stage2_Ctl_Branch1;
wire [3:0] Stage2_ALU_ctl;
wire [1:0] Stage2_forwarding;
wire [4:0] Stage2_Rd;
wire [31:0] Stage2_ReadData1, Stage2_ReadData2;
wire [31:0] Stage2_Immediate;
wire [7:0]  Stage2_PC4;

wire Stage3_Ctl_MemtoReg, Stage3_Ctl_RegWrite;
wire [4:0] Stage3_Rd;
wire [31:0] ALUresult, MemWriteData;//비동기이므로 stage이름을 안 붙였다.

wire [31:0] RegWriteData, LoadData;//비동기 출력
wire c, NOS;
wire [ 1:0] LED_clk;
	
////////////////////////////////////////////////
`ifdef simulation
	wire	[31:0] data = clk_count;
	wire 	[31:0] RAM_address = ALUresult;
`else
	wire pass;
	assign 		 LED = {pass, data[30:16]};
	wire	[31:0] clk_address, clk_count;
	wire 	[31:0] data = (key[1])? LoadData : clk_count;
	wire 	[31:0] RAM_address = (key[1]) ? (clk_address<<2) : ALUresult;
`endif
	
//////////////////////////////////////////////////////////////////////////////////////
	LED_channel LED0(
	.data(data),							.digit(digit),
	.LED_clk(LED_clk),					.fnd(fnd));
//////////////////////////////////////////////////////////////////////////////////////
	counter A0_counter(
`ifndef simulation
	.key1(key[1]),
	.mem_data(LoadData),
	.pass(pass),
	.clk_address(clk_address),
	
	.Switch(Switch),
`endif
	
	.clk(clk),								.LED_clk(LED_clk),
	.rst(rst),								.clk_out(c),
	.pc_in(Stage2_PC4),				.clk_count_out(clk_count));
//////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////
STAGE1 STAGE1(
.clk(c), .rst(rst),
.Ctl_RegWrite_in(Stage3_Ctl_RegWrite), 
.WriteReg_in(Stage3_Rd),
.WriteData_in(RegWriteData),
.ALUresult_in(ALUresult),

.Ctl_ALUSrc(Stage2_Ctl_ALUSrc), 
.Ctl_MemtoReg(Stage2_Ctl_MemtoReg), 
.Ctl_RegWrite(Stage2_Ctl_RegWrite), 
.Ctl_MemWrite(Stage2_Ctl_MemWrite), 
.Ctl_Branch1(Stage2_Ctl_Branch1), //Ctl_Branch0,
.ALUctl(Stage2_ALU_ctl),
.EXE_forwarding_out(Stage2_forwarding),

.Rd_out(Stage2_Rd), 
.ReadData1_out(Stage2_ReadData1), 
.ReadData2_out(Stage2_ReadData2), 
.Immediate_out(Stage2_Immediate),
.PC4_out(Stage2_PC4),
.NOS(NOS)
);
/////////////////////////////////////////////////
STAGE2 STAGE2(
.clk(c), .rst(rst), .NOS(NOS),
.Ctl_ALUSrc_in(Stage2_Ctl_ALUSrc), 
.Ctl_MemtoReg_in(Stage2_Ctl_MemtoReg), 
.Ctl_RegWrite_in(Stage2_Ctl_RegWrite), 
.Ctl_Branch1_in(Stage2_Ctl_Branch1), //Ctl_Branch0,
.ALU_ctl_in(Stage2_ALU_ctl),
.EXE_forwarding_in(Stage2_forwarding),

.Rd_in(Stage2_Rd), 
.ReadData1_in(Stage2_ReadData1), 
.ReadData2_in(Stage2_ReadData2), 
.Immediate_in(Stage2_Immediate),
.WriteData_in(RegWriteData),
.PC4_in(Stage2_PC4), 

.Ctl_MemtoReg_out(Stage3_Ctl_MemtoReg), 
.Ctl_RegWrite_out(Stage3_Ctl_RegWrite), 
.Rd_out(Stage3_Rd),
.ALUresult_out(ALUresult),
.MemWriteData_out(MemWriteData)
);
//////////////////////////////////////////////////////////
STAGE3 STAGE3(
.clk(c), .rst(rst),
.Ctl_MemtoReg_in(Stage3_Ctl_MemtoReg), 
.Ctl_MemWrite_in(Stage2_Ctl_MemWrite),
.Write_Data_in(MemWriteData), 
.ALUresult_in(RAM_address), 

.WriteData_out(RegWriteData), 
.LoadData(LoadData)
);
	 
endmodule
