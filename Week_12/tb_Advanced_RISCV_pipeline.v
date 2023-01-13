`timescale 1ns / 1ps

module tb_Advanced_RISCV_pipeline;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [31:0] current_pc;
	wire [31:0] instruction;
	wire Hazard_exe_ctl_MemRead_in;
	wire [4:0] Hazard_Rd_in;
	wire [9:0] Hazard_instruction_in;
	wire Hazard_stall_out;
	wire [4:0] Hazard_Rs1_in;
	wire [4:0] Hazard_Rs2_in;
	wire Forwarding_mem_ctl_RegWrite_in;
	wire Forwarding_wb_Ctl_RegWrite_in;
	wire [4:0] Forwarding_Rs1_in;
	wire [4:0] Forwarding_Rs2_in;
	wire [4:0] Forwarding_mem_Rd_in;
	wire [4:0] Forwarding_wb_Rd_in;
	wire [1:0] Forwarding_ForwardA_out;
	wire [1:0] Forwarding_ForwardB_out;
	wire [4:0] InDecode_Rd_out;
	wire [4:0] InDecode_Rs1_out;
	wire [4:0] InDecode_Rs2_out;
	wire [31:0] InDecode_PC_out;
	wire [31:0] InDecode_ReadData1_out;
	wire [31:0] InDecode_ReadData2_out;
	wire [31:0] InDecode_Immediate_out;
	wire Execution_zero_out;
	wire [31:0] Execution_ALUresult_out;
	wire [31:0] Memory_Write_Data;
	wire [31:0] Memory_Read_Data;
	wire [31:0] Memory_ALUresult_out;
	wire [31:0] WB_WriteDatatoReg_out;
	wire [4:0] WB_Rd_in;
	wire [31:0] WB_ReadDatafromMem_in;
	wire [31:0] WB_ALUresult_in;
	wire WB_Ctl_RegWrite_out;

	// Instantiate the Unit Under Test (UUT)
	Advanced_RISCV_pipeline uut (
		.current_pc(current_pc), 
		.instruction(instruction), 
		.clk(clk), 
		.rst(rst), 
		.Hazard_exe_ctl_MemRead_in(Hazard_exe_ctl_MemRead_in), 
		.Hazard_Rd_in(Hazard_Rd_in), 
		.Hazard_instruction_in(Hazard_instruction_in), 
		.Hazard_stall_out(Hazard_stall_out), 
		.Hazard_Rs1_in(Hazard_Rs1_in), 
		.Hazard_Rs2_in(Hazard_Rs2_in), 
		.Forwarding_mem_ctl_RegWrite_in(Forwarding_mem_ctl_RegWrite_in), 
		.Forwarding_wb_Ctl_RegWrite_in(Forwarding_wb_Ctl_RegWrite_in), 
		.Forwarding_Rs1_in(Forwarding_Rs1_in), 
		.Forwarding_Rs2_in(Forwarding_Rs2_in), 
		.Forwarding_mem_Rd_in(Forwarding_mem_Rd_in), 
		.Forwarding_wb_Rd_in(Forwarding_wb_Rd_in), 
		.Forwarding_ForwardA_out(Forwarding_ForwardA_out), 
		.Forwarding_ForwardB_out(Forwarding_ForwardB_out), 
		.InDecode_Rd_out(InDecode_Rd_out), 
		.InDecode_Rs1_out(InDecode_Rs1_out), 
		.InDecode_Rs2_out(InDecode_Rs2_out), 
		.InDecode_PC_out(InDecode_PC_out),
		.InDecode_ReadData1_out(InDecode_ReadData1_out), 
		.InDecode_ReadData2_out(InDecode_ReadData2_out), 
		.InDecode_Immediate_out(InDecode_Immediate_out), 
		.Execution_zero_out(Execution_zero_out), 
		.Execution_ALUresult_out(Execution_ALUresult_out), 
		.Memory_Write_Data(Memory_Write_Data), 
		.Memory_Read_Data(Memory_Read_Data), 
		.Memory_ALUresult_out(Memory_ALUresult_out), 
		.WB_WriteDatatoReg_out(WB_WriteDatatoReg_out), 
		.WB_Rd_in(WB_Rd_in), 
		.WB_ReadDatafromMem_in(WB_ReadDatafromMem_in), 
		.WB_ALUresult_in(WB_ALUresult_in), 
		.WB_Ctl_RegWrite_out(WB_Ctl_RegWrite_out)
	);

	initial begin
		rst=1;
		#54 rst=0;
	end

	initial begin
		clk=0;
		forever #5 clk = ~clk;
	end      
endmodule