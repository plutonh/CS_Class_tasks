`timescale 1ns / 1ps
`include "./config.vh"
module Advanced_RISCV_pipeline(
	
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
//모든 wire이름은 생성되는 곳이 아니라 사용하는 곳을 이니셜로 사용함
//예외 항목들은 아래 기재
//MEM: PCSrc, stall, flush
//WB: wb_mux_out
//ForwardA, ForwardB
wire 			c;
wire [ 1:0] LED_clk;
wire PCSrc;
wire ind_ctl_RegWrite;
wire exe_ctl_ALUSrc, exe_ctl_MemtoReg, exe_ctl_RegWrite, exe_ctl_MemRead, exe_ctl_MemWrite, exe_ctl_Branch, exe_ctl_ALUOp1, exe_ctl_ALUOp2;
wire exe_jal, exe_jalr;
wire mem_ctl_MemtoReg, mem_ctl_RegWrite, mem_ctl_MemRead, mem_ctl_MemWrite, mem_ctl_Branch, mem_jal, mem_jalr, mem_zero;
wire wb_ctl_MemtoReg,  wb_ctl_RegWrite, wb_jal, wb_jalr;
wire stall, flush;

wire [31:0] if_pc_branch, ind_pc, exe_pc, mem_pc, wb_pc;
wire [31:0] ind_ins;
wire [31:0] exe_data1, exe_data2, exe_imm, mem_pc_imm, mem_addr, mem_result, mem_data2, wb_result, wb_data, wb_mux_out;
wire [4:0] 	ind_rd, exe_rd, exe_rs1, exe_rs2, mem_rd, wb_rd;
wire  exe_inst30;
wire [2:0] 	exe_funct3;
wire [1:0]	ForwardA, ForwardB;

assign flush = PCSrc;

`ifdef simulation
	wire	[31:0] data = clk_count;
	wire 	[31:0] RAM_address = mem_result;
`else
	assign 		 LED = {pass, data[30:16]};
	wire	[31:0] clk_address, clk_count;
	wire 	[31:0] data = (key[1])? wb_data : clk_count;
	wire 	[31:0] RAM_address = (key[1]) ? (clk_address<<2) : mem_result;
`endif

//////////////////////////////////////////////////////////////////////////////////////
	LED_channel LED0(
	.data(data),							.digit(digit),
	.LED_clk(LED_clk),					.fnd(fnd));
//////////////////////////////////////////////////////////////////////////////////////
	counter A0_counter(
`ifndef simulation
	.key1(key[1]),
	.mem_data(wb_data),
	.pass(pass),
	.clk_address(clk_address),
	
	.Switch(Switch),
	
`endif

	.clk(clk),								.LED_clk(LED_clk),
	.rst(rst),								.clk_out(c),
	.pc_in(ind_pc),						.clk_count_out(clk_count));

//////////////////////////////////////////////////////////////////////////////////////


////////////////////////
InFetch A1_InFetch(
.clk(c),
.reset(rst),
.PCSrc(PCSrc),
.stall(stall),
.PC_branch_in(if_pc_branch),
.instruction_out(ind_ins),
.PC_out(ind_pc)
);

////////////////////////
InDecode A3_InDecode(
.clk(c),
.reset(rst),
.stall(stall),
.flush(flush),

.Ctl_RegWrite_in(ind_ctl_RegWrite),
.Ctl_ALUSrc_out(exe_ctl_ALUSrc),
.Ctl_MemtoReg_out(exe_ctl_MemtoReg),
.Ctl_RegWrite_out(exe_ctl_RegWrite),
.Ctl_MemRead_out(exe_ctl_MemRead),
.Ctl_MemWrite_out(exe_ctl_MemWrite),
.Ctl_Branch_out(exe_ctl_Branch),
.Ctl_ALUOpcode1_out(exe_ctl_ALUOp1),
.Ctl_ALUOpcode0_out(exe_ctl_ALUOp2),

.WriteReg_in(ind_rd),
.PC_in(ind_pc),
.instruction_in(ind_ins),
.WriteData(wb_mux_out),

.Rd_out(exe_rd),
.Rs1_out(exe_rs1),
.Rs2_out(exe_rs2),
.PC_out(exe_pc),
.ReadData1_out(exe_data1),
.ReadData2_out(exe_data2),
.Immediate_out(exe_imm),
.inst30_out(exe_inst30),
.funct3_out(exe_funct3),
.jalr_out(exe_jalr),
.jal_out(exe_jal)
);
////////////////////////
Execution A4_Execution(
.clk(c),
.reset(rst),
.flush(flush),

.Ctl_ALUSrc_in(exe_ctl_ALUSrc),
.Ctl_MemtoReg_in(exe_ctl_MemtoReg),
.Ctl_RegWrite_in(exe_ctl_RegWrite),
.Ctl_MemRead_in(exe_ctl_MemRead),
.Ctl_MemWrite_in(exe_ctl_MemWrite),
.Ctl_Branch_in(exe_ctl_Branch),
.Ctl_ALUOpcode1_in(exe_ctl_ALUOp1),
.Ctl_ALUOpcode0_in(exe_ctl_ALUOp2),

.Ctl_MemtoReg_out(mem_ctl_MemtoReg),
.Ctl_RegWrite_out(mem_ctl_RegWrite),
.Ctl_MemRead_out(mem_ctl_MemRead),
.Ctl_MemWrite_out(mem_ctl_MemWrite),
.Ctl_Branch_out(mem_ctl_Branch),

.Rd_in(exe_rd),
.Rs2_in(exe_rs2),
.Rd_out(mem_rd),
.jal_in(exe_jal),
.jalr_in(exe_jalr),
.jal_out(mem_jal),
.jalr_out(mem_jalr),

.Immediate_in(exe_imm),
.ReadData1_in(exe_data1),
.ReadData2_in(exe_data2),
.ex_mem_data_in(mem_result),
.wb_data_in(wb_mux_out),
.PC_in(exe_pc),
.inst30_in(exe_inst30),
.funct3_in(exe_funct3),
.ForwardA_in(ForwardA),
.ForwardB_in(ForwardB),

.Zero_out(mem_zero),
.ALUresult_out(mem_result),
.PCimm_out(mem_addr),
.ReadData2_out(mem_data2),
.PC_out(mem_pc)
);
////////////////////////
Memory A6_Memory(
.reset(rst),
.clk(c),

.Ctl_MemtoReg_in(mem_ctl_MemtoReg),
.Ctl_RegWrite_in(mem_ctl_RegWrite),
.Ctl_MemRead_in(mem_ctl_MemRead),
.Ctl_MemWrite_in(mem_ctl_MemWrite),
.Ctl_Branch_in(mem_ctl_Branch),

.Ctl_MemtoReg_out(wb_ctl_MemtoReg),
.Ctl_RegWrite_out(wb_ctl_RegWrite),

.Rd_in(mem_rd),
.Rd_out(wb_rd),
.jal_in(mem_jal),
.jalr_in(mem_jalr),
.jal_out(wb_jal),
.jalr_out(wb_jalr),

.Zero_in(mem_zero),
.Write_Data_in(mem_data2),
.ALUresult_in(RAM_address),
.PCimm_in(mem_addr),
.PC_in(mem_pc),
.PCSrc_out(PCSrc),
.Read_Data_out(wb_data),
.ALUresult_out(wb_result),
.PC_branch_out(if_pc_branch),
.PC_out(wb_pc)
);
////////////////////////
WB A7_WB(
.Ctl_RegWrite_in(wb_ctl_RegWrite),
.Ctl_MemtoReg_in(wb_ctl_MemtoReg),

.jal_in(wb_jal),
.jalr_in(wb_jalr),
.PC_in(wb_pc),
.Rd_in(wb_rd),
.ReadDatafromMem_in(wb_data),
.ALUresult_in(wb_result),

.Rd_out(ind_rd),
.Ctl_RegWrite_out(ind_ctl_RegWrite),
.WriteDatatoReg_out(wb_mux_out)
);
////////////////////////
Hazard_detection_unit A2_Hazard(
.exe_Ctl_MemRead_in(exe_ctl_MemRead),
.Rd_in(exe_rd),
.instruction_in(ind_ins[24:15]),
.stall_out(stall)
);

Forwarding_unit A5_forwarding(
.MEM_Ctl_RegWrite_in(mem_ctl_RegWrite), 
.WB_Ctl_RegWrite_in(wb_ctl_RegWrite),
.Rs1_in(exe_rs1), 
.Rs2_in(exe_rs2),
.EX_MEM_Rd_in(mem_rd), 
.MEM_WB_Rd_in(wb_rd),
.ForwardA_out(ForwardA), 
.ForwardB_out(ForwardB)
);

endmodule
