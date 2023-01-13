module RISCVpipeline(

output [31:0] current_pc,
output [31:0] instruction,

input clk, rst
);
wire c;
wire [1:0] LED_clk;
wire [31:0] pc, ins;
wire exe_ctl_0, exe_ctl_1, exe_ctl_2, exe_ctl_3, exe_ctl_4, exe_ctl_5, exe_ctl_6, exe_ctl_7;
wire mem_ctl_1, mem_ctl_2, mem_ctl_3, mem_ctl_4, mem_ctl_5, mem_ctl_6;
wire wb_ctl_0,  wb_ctl_1,  wb_ctl_2, wb_ctl_3;

wire [31:0]  ind_pc;
   wire [31:0] ind_data1, ind_data2, ind_imm, exe_data2, exe_addr, exe_result, mem_addr, mem_result, mem_data, wb_data;
wire [4:0] ind_rd, ind_rs1, ind_rs2, exe_rd, mem_rd, wb_rd;
wire [6:0] ind_funct7;
wire [2:0] ind_funct3;
wire ind_jal, ind_jalr, exe_zero, mem_PCSrc;

assign current_pc = pc;
assign instruction = ins;
////////////////////////
InFetch A1_InFetch(
.clk(clk),
.reset(rst),
.PCSrc(mem_PCSrc),
.PCimm_in(mem_addr),
.instruction_out(ins),
.PC_out(pc)
);
////////////////////////
InDecode A3_InDecode(
.Ctl_RegWrite_in(wb_ctl_3),
.Ctl_ALUSrc_out(exe_ctl_0),
.Ctl_MemtoReg_out(exe_ctl_1),
.Ctl_RegWrite_out(exe_ctl_2),
.Ctl_MemRead_out(exe_ctl_3),
.Ctl_MemWrite_out(exe_ctl_4),
.Ctl_Branch_out(exe_ctl_5),
.Ctl_ALUOpcode1_out(exe_ctl_6),
.Ctl_ALUOpcode0_out(exe_ctl_7),
.WriteReg(WriteReg),
.PC_in(pc),
.instruction_in(ins),
.WriteData(wb_data),
.Rd_out(ind_rd),
.Rs1_out(ind_rs1),
.Rs2_out(ind_rs2),
.PC_out(ind_pc),
.ReadData1_out(ind_data1),
.ReadData2_out(ind_data2),
.Immediate_out(ind_imm),
.funct7_out(ind_funct7),
.funct3_out(ind_funct3),
.jalr_out(ind_jalr),
.jal_out(ind_jal),
.clk(clk),
.reset(rst)
);
////////////////////////
Execution A4_Execution(
.clk(clk),
.Ctl_ALUSrc_in(exe_ctl_0),
.Ctl_MemtoReg_in(exe_ctl_1),
.Ctl_RegWrite_in(exe_ctl_2),
.Ctl_MemRead_in(exe_ctl_3),
.Ctl_MemWrite_in(exe_ctl_4),
.Ctl_Branch_in(exe_ctl_5),
.Ctl_ALUOpcode1_in(exe_ctl_6),
.Ctl_ALUOpcode0_in(exe_ctl_7),
.Ctl_MemtoReg_out(mem_ctl_1),
.Ctl_RegWrite_out(mem_ctl_2),
.Ctl_MemRead_out(mem_ctl_3),
.Ctl_MemWrite_out(mem_ctl_4),
.Ctl_Branch_out(mem_ctl_5),
.Rd_in(ind_rd),
.Rd_out(exe_rd),
.Immediate_in(ind_imm),
.ReadData1_in(ind_data1),
.ReadData2_in(ind_data2),
.PC_in(ind_pc),
.funct7_in(ind_funct7),
.funct3_in(ind_funct3),
.Zero_out(exe_zero),
.ALUresult_out(exe_result),
.PCimm_out(mem_addr),
.ReadData2_out(exe_data2)
);
////////////////////////
Memory A6_Memory(
.reset(rst),
.clk(clk),
.Ctl_MemtoReg_in(mem_ctl_1),
.Ctl_RegWrite_in(mem_ctl_2),
.Ctl_MemRead_in(mem_ctl_3),
.Ctl_MemWrite_in(mem_ctl_4),
.Ctl_Branch_in(mem_ctl_5),
.Ctl_MemtoReg_out(wb_ctl_1),
.Ctl_RegWrite_out(wb_ctl_2),
.Rd_in(exe_rd),
.Rd_out(mem_rd),
.Zero_in(exe_zero),
.Write_Data(exe_data2),
.ALUresult_in(exe_result),
.PCimm_in(mem_addr),
.PCSrc(mem_PCSrc),
.Read_Data(mem_data),
.ALUresult_out(mem_result),
.PCimm_out(mem_addr)
);
////////////////////////
WB A7_WB(
.Ctl_RegWrite_in(wb_ctl_2),
.Ctl_MemtoReg_in(wb_ctl_1),
.Ctl_RegWrite_out(wb_ctl_3),
.Rd_in(mem_rd),
.ReadDatafromMem_in(mem_data),
.ALUresult_in(mem_result),
.Rd_out(wb_rd),
.WriteDatatoReg_out(wb_data)
);

endmodule