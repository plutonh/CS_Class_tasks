`timescale 1ns / 1ps

`define JAL     5'b11011      // jal   rd,imm[xxxxx]
`define JALR    5'b11001      // jalr  rd,rs1,imm[11:0]
`define BCC     5'b11000      // bcc   rs1,rs2,imm[12:1]
`define LCC     5'b00000      // lxx   rd,rs1,imm[11:0]
`define SCC     5'b01000      // sxx   rs1,rs2,imm[11:0]
`define MCC     5'b00100      // xxxi  rd,rs1,imm[11:0]
`define RCC     5'b01100      // xxx   rd,rs1,rs2


//`include "./config.vh"

module InDecode(
input clk, reset,
input stall, flush,

input Ctl_RegWrite_in,	//from WB stage
// control signal out
output reg Ctl_ALUSrc_out, Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out, Ctl_MemWrite_out, Ctl_Branch_out, Ctl_ALUOpcode1_out, Ctl_ALUOpcode0_out,

input [ 4:0] WriteReg_in, //reg address 5 bits = 32 addresses
input [31:0] PC_in, instruction_in, WriteData,

output reg [ 4:0] Rd_out, Rs1_out, Rs2_out,
output reg [31:0] PC_out, ReadData1_out, ReadData2_out, Immediate_out,
output reg inst30_out,
output reg [ 2:0] funct3_out, 
output reg jalr_out, jal_out
);
wire [ 4:0] opcode = instruction_in[6:2];
wire inst30 = instruction_in[30];
wire [ 2:0] funct3 = instruction_in[14:12];
wire [ 4:0] Rd = instruction_in[11:7];
wire [ 4:0] Rs1 = instruction_in[19:15];
wire [ 4:0] Rs2 = instruction_in[24:20];
wire   jalr = (opcode==`JALR )?1:0;
wire   jal = (opcode==`JAL  )?1:0;
wire [ 7:0] Ctl_out;
reg [ 7:0] Control;

// control unit RISC-V
Control_unit B0 (.opcode(opcode), .Ctl_out(Ctl_out), .reset(reset));

// Allocate as an if statement considering x and z.
always @(*) begin
	if (flush||stall) Control = 8'b0;
	else Control = Ctl_out;
end


//Register
parameter reg_size = 32;
reg [31:0] Reg[0:reg_size-1]; //32bit reg


integer i;
always@(posedge clk) begin
	if(reset) begin
		for(i=0; i<32; i=i+1)
			Reg[i] <= 32'b0;
		Reg[1] <= 2;
		Reg[2] <= 3;
		Reg[3] <= 4;
		Reg[4] <= 5;
		Reg[5] <= 6;
		Reg[6] <= 7;
	end
	else if(Ctl_RegWrite_in && WriteReg_in!=0)
		Reg[WriteReg_in] <= WriteData;
end

//Immediate Generator - sign extention RISC-V
reg [31:0] Immediate;
always@(*) begin
	case(opcode)
		`LCC:	Immediate = $signed(instruction_in[31:20]); // I-type load
		`MCC:	Immediate = $signed(instruction_in[31:20]); // I-type addi, ori 등	//shift imme은 logical
		`JALR: Immediate = $signed(instruction_in[31:20]); // I-type jalr
		`SCC: Immediate = $signed({instruction_in[31:25],instruction_in[11:7]}); // S-type
		`BCC: Immediate = $signed({instruction_in[31],instruction_in[7],instruction_in[30:25],instruction_in[11:8]}); // SB-type
		`JAL: Immediate = $signed({instruction_in[31],instruction_in[19:12],instruction_in[20],instruction_in[30:21]}); // jal    
		default: Immediate = 32'b0;
	endcase
end



//ID/EX reg write
always@(posedge clk) begin
// RISC-V
	PC_out 		<= (reset)? 0 : PC_in;
	inst30_out 	<=	(reset)? 0 : inst30;
	funct3_out 	<= (reset)? 0 : funct3;
	Rd_out 		<=	(reset)? 0 : Rd;
	Rs1_out 		<=	(reset)? 0 : Rs1;
	Rs2_out 		<= (reset)? 0 : Rs2;
	//Write when WBreg is positive edge, so RF cannot write when wb stage. Therefore, ID/EX requires bypass.
	ReadData1_out 	<= (reset)? 0 : (Ctl_RegWrite_in && WriteReg_in==Rs1) ? WriteData : Reg[Rs1];
	ReadData2_out 	<= (reset)? 0 : (Ctl_RegWrite_in && WriteReg_in==Rs2) ? WriteData : Reg[Rs2];
	jalr_out 		<= (reset)? 0 : jalr;
	jal_out 			<= (reset)? 0 : jal;
	Ctl_ALUSrc_out <= (reset)? 0 : Control[7];
	Ctl_MemtoReg_out 		<= (reset)? 0 : Control[6];
	Ctl_RegWrite_out 		<= (reset)? 0 : Control[5];
	Ctl_MemRead_out 		<= (reset)? 0 : Control[4];
	Ctl_MemWrite_out 		<= (reset)? 0 : Control[3];
	Ctl_Branch_out 		<= (reset)? 0 : Control[2];
	Ctl_ALUOpcode1_out 	<= (reset)? 0 : Control[1];
	Ctl_ALUOpcode0_out 	<= (reset)? 0 : Control[0];
	Immediate_out 			<= (reset)? 0 : Immediate;
end

endmodule

////////////////////////////////////////////////////////////////////////////////////
module Control_unit(
input [4:0] opcode,
input reset,
output reg [7:0] Ctl_out
);

always @(*) begin
	if (reset) // control unit must reset to zero
		Ctl_out = 8'b0;
	else
	case(opcode) // [7] [6] [5] [4] [3] [2]
		// add, sub, ... 
		`RCC : Ctl_out = 8'b001000_10; // R-type - - RegWrite - - -
		// addi, slli : shift left logical immediate rd = rs1 << imm
		`MCC : Ctl_out = 8'b101000_11; // I-type    xxxi  rd, rs1,imm[11:0] ALUSrc - RegWrite - - -
		// lw 
		`LCC : Ctl_out = 8'b111100_00; // I-type    lxx   rd, rs1,imm[11:0] ALUSrc MemtoReg RegWrite MemRead - -
		// sw 
		`SCC : Ctl_out = 8'b100010_00; // S-type    sxx   rs1,rs2,imm[11:0] ALUSrc - - - MemWrite -
		// beq : branch equal : go to PC+imm<<1
		`BCC : Ctl_out = 8'b000001_01; // SB-type   bcc   rs1,rs2,imm[12:1] - - - - - Branch
		// jal : jump and link : rd = PC+4, go to PC+imm<<1 
		`JAL : Ctl_out = 8'b001001_00; // UJ-type   jal rd, imm[20:1] - - RegWrite - - Branch
		// jalr : jump and link register : rd = PC+4, go to rs1+imm 
		`JALR : Ctl_out = 8'b101001_11; // I-type   jalr  rd, rs1,imm[11:0] ALUSrc - RegWrite - - Branch
		
		default : Ctl_out = 8'b0; // control unit make sure to make an exception with 0
	endcase
end
endmodule