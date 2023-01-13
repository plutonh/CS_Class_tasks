`timescale 1ns / 1ps
//13.401ns

`define JAL     5'b11011      // jal   rd,imm[xxxxx]
`define JALR    5'b11001      // jalr  rd,rs1,imm[11:0]
`define BCC     5'b11000      // bcc   rs1,rs2,imm[12:1]
`define LCC     5'b00000      // lxx   rd,rs1,imm[11:0]
`define SCC     5'b01000      // sxx   rs1,rs2,imm[11:0]
`define MCC     5'b00100      // xxxi  rd,rs1,imm[11:0]
`define RCC     5'b01100      // xxx   rd,rs1,rs2

//ALU OPERATION
`define _AND_	4'b0000
`define _OR_	4'b0001
`define _ADD_	4'b0010
`define _SUB_	4'b0110
`define _BEQ_	4'b0111	
`define _BNE_	4'b1000	
`define _JAL_	4'b0011	
`define _JALR_	4'b0010	//ADD�� �ڵ� ����
`define _BLT_	4'b0111
`define _BGE_	4'b1011
`define _NOR_	4'b1100
`define _SLL_	4'b1001
`define _SRL_	4'b1010

//`include "./config.vh"

module InDecode(
input clk, rst, NOP,
input Ctl_RegWrite_in,	//from WB stage
// control signal out
output reg Ctl_ALUSrc_out, Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemWrite_out, Ctl_Branch1_out, //Ctl_Branch0_out,
output reg [3:0] ALUctl_out,
output reg [1:0] EXE_forwarding_out,

input [ 4:0] WriteReg_in, //reg�ּ� 5bit = 32���� �ּ�
input [31:0] WriteData, instruction_in, ALUresult_in,

output reg [ 4:0] Rd_out, 
output reg [31:0] ReadData1_out, ReadData2_out, 
output reg [31:0] Immediate_out,
output reg [7:0]  PC4_out, 
output [7:0] PC_next,
output NOS
 );
 

wire [ 4:0] opcode = instruction_in[6:2];
wire inst30 = instruction_in[30];
wire [ 2:0] funct3 = instruction_in[14:12];

wire [4:0] Rd = instruction_in[11:7];
wire [4:0] Rs1 = instruction_in[19:15];
wire [4:0] Rs2 = instruction_in[24:20];


// control unit RISC-V
wire [3:0] ALUctl;
wire [4:0] Ctl_out;
Control_unit Control_unit(.opcode(opcode), .funct3(funct3), .inst30(inst30), .Ctl_out(Ctl_out), .ALUctl(ALUctl));
wire [4:0] Control = (NOS) ? 5'bx000x : Ctl_out;
//PC_next�� 0�� ��� �ƹ� ���굵 �� ��
//bubble�� �ϵ���������� nop�� �����ϰ� �����ν� �����ߴ�.


//Register File
wire [31:0] ReadData1, ReadData2;
wire [1:0] EXE_forwarding;
Register_File RF(
.clk(clk), .rst(rst),
.Ctl_RegWrite_in(Ctl_RegWrite_in), 
.EXE_Ctl_MemtoReg_in(Ctl_MemtoReg_out),
.EXE_Ctl_RegWrite_in(Ctl_RegWrite_out),
.Rs1(Rs1), .Rs2(Rs2), 
.EXE_Rd_in(Rd_out),
.WriteReg_in(WriteReg_in),
.WriteData_in(WriteData),
.ALUresult_in(ALUresult_in),
.ReadData1_out(ReadData1), .ReadData2_out(ReadData2),
.EXE_forwarding(EXE_forwarding)
);




//Immediate Generator - sign extention RISC-V
reg [31:0] Immediate;
always@(*) begin
	case(opcode)	//�츮 pc�� 4�ڸ����� �����ϹǷ� 4�� �ڸ����� �����ϰ� ����, 8���̸� ����ϰ� ����.
		`LCC:	begin
			Immediate = $signed(instruction_in[31:20]); // I-type load
		end
		`MCC:	begin
			Immediate = $signed(instruction_in[31:20]); // I-type addi, ori ��	//shift imme�� logical���� �� ��.
		end
/*		`JALR:begin
			//Immediate = $signed(instruction_in[31:20]); // I-type jalr. JALR�� imme�� 1�� �ڸ����� ����
			Immediate = $signed(instruction_in[31:22]);
		end
*/		`SCC: begin
			Immediate = $signed({instruction_in[31:25],instruction_in[11:7]}); // S-type
		end
		`BCC: begin
			//Immediate = $signed({instruction_in[31],instruction_in[7],instruction_in[30:25],instruction_in[11:8]}); // SB-type
			Immediate = $signed({instruction_in[30:25],instruction_in[11:9]}); 
		end
		`JAL: begin
			//Immediate = $signed({instruction_in[31],instruction_in[19:12],instruction_in[20],instruction_in[30:21]}); // jal    
			Immediate = $signed(instruction_in[30:22]);
		end
		default: begin
			Immediate = 32'bx;
		end
	endcase
end



//ID/EXE reg
always @(posedge clk) begin
	PC4_out 		<=	PC4;
	Rd_out 		<=	Rd;
	
	//�̹� forwarding 1���� �Ϸ�� ������
	ReadData1_out 	<= ReadData1;
	ReadData2_out 	<= ReadData2;
	
	Ctl_ALUSrc_out 		<= Control[4];
	Ctl_MemtoReg_out 		<= Control[3];
	//Rd=0�̸� �׻� RegWrite=0�̴�. ->�ϵ���� �ܼ�ȭ
	Ctl_RegWrite_out 		<= (Rd==5'b0)? 1'b0 : Control[2];
	Ctl_MemWrite_out 		<= Control[1];
	Ctl_Branch1_out		<= Control[0];
	ALUctl_out				<=	ALUctl;
	EXE_forwarding_out	<= EXE_forwarding;

	Immediate_out 			<= Immediate;
end

//NEXT_PC unit. ��ü ALU�� branch�� �Ǻ�.
wire [7:0] PC4;
NEXT_PC NEXT_PC(
.clk(clk), .rst(rst), .NOP(NOP),
.inst_type({opcode[4], opcode[1:0]}), 
.funct2({funct3[2],funct3[0]}),
.imme(Immediate[7:0]),
.Data1(ReadData1), .Data2(ReadData2),
.PC_next(PC_next),
.PC4(PC4),
.NOS(NOS)
    );
	 
	  
	 
endmodule

////////////////////////////////////////////////////////////////////////////////////
module Control_unit(
input [4:0] opcode,
input [2:0] funct3,
input inst30,
output reg [4:0] Ctl_out,
output reg [3:0] ALUctl
);

//flushó���� �����ؾ� �Ѵ�. x�� ���� �Ἥ �ܼ��� 0���� �ִ� �� flush�� �� �ȴ�.
//EXE stage���� �����Դ�. �̰� �߰��ص� timing�� ��ȭ�� ����.
//����ϴ� ��� branch�� ID���� ó���ǹǷ� branch0��ȣ�� ���ʿ��ϴ�. 1��ȣ�� jal, jalr�� �ǹ��Ѵ�.
always @(*) begin
casex ({opcode,funct3,inst30})
	{`LCC, 4'bxxx_x} :begin 
							ALUctl = `_ADD_; // lb, lh, lw => ADDITION
							Ctl_out = 5'b1110_0;//0; // ld  rd, rs1,imm[11:0] ALUSrc MemtoReg RegWrite _ Branch(00)
							end
	{`SCC, 4'bxxx_x} :begin 
							ALUctl = `_ADD_; // sb, sh, sw => ADDITION
							Ctl_out = 5'b1001_0;//0; // sd  rs1,rs2,imm[11:0] ALUSrc - - MemWrite -
							end
	{`JAL, 4'bxxx_x} :begin 
							ALUctl = 4'bx;//`_JAL_;	
							Ctl_out = 5'b0010_1;//0; // jal  rd, imm[20:1] - - RegWrite - Branch(10)
							end
	{`JALR, 4'bxxx_x} :begin
							ALUctl = 4'bx;//`_JALR_;
							Ctl_out = 5'b1010_1;//1; // jalr  rd, rs1,imm[11:0] ALUSrc - RegWrite - - Branch(11)
							end
/*	{`BCC, 4'b000_x} :begin 
							ALUctl = `_BEQ_; // beq(funct3==3'b000)
							Ctl_out = 5'b0000_0//1; // beq   rs1,rs2,imm[12:1] - - - - - Branch(01)
							end
	{`BCC, 4'b001_x} :begin 
							ALUctl = `_BNE_; // bne(funct3==3'b001)
							Ctl_out = 5'b0000_0//1; // bne   rs1,rs2,imm[12:1] - - - - - Branch(10)
							end
					
	{`BCC, 4'b100_x} :begin 
							ALUctl = `_BLT_; // blt => BLT(branch if less than) (funct3==3'b100)
							Ctl_out = 5'b0000_0;//1; // blt   rs1,rs2,imm[12:1] - - - - - Branch(01)
							end
	{`BCC, 4'b101_x} : begin
							ALUctl = `_BGE_; // bge => BGE(branch if greater than) (funct3==3'b101)
							Ctl_out = 5'b0000_0;//1; // bge   rs1,rs2,imm[12:1] - - - - - Branch(01)
							end
*/							
	{`RCC, 4'b000_0} :begin 
							ALUctl = `_ADD_; // add => ADDITION (funct3==3'b000 && funct7==7'b0000000)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end
	{`RCC, 4'b000_1} :begin 
							ALUctl = `_SUB_; // sub => SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end
	{`RCC, 4'b001_0} :begin 
							ALUctl = `_SLL_; // sub => SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end							
	{`RCC, 4'b101_0} :begin 
							ALUctl = `_SRL_; // sub => SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end				
	{`RCC, 4'b111_0} :begin
							ALUctl = `_AND_; // and => AND (funct3==3'b111 && ALUop==1x)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end
/*	{`RCC, 4'b110_0} :begin
							ALUctl = `_OR_;  // or => OR (funct3==3'b110 && ALUop=1x)
							Ctl_out = 5'b0010_0;//0; // R-type - - RegWrite - - -
							end
*/	{`MCC, 4'b000_x} :begin 
							ALUctl = `_ADD_; // addi, jalr => ADDITION (funct3==3'b000)
							Ctl_out = 5'b1010_0;//0; // I-type    xxxi  rd, rs1,imm[11:0] ALUSrc - RegWrite - - -
							end
	{`MCC, 4'b001_0} :begin
							ALUctl = `_SLL_; // slli => SHIFT_LEFT (funct3==3'b001)
							Ctl_out = 5'b1010_0;//0; // I-type    xxxi  rd, rs1,imm[11:0] ALUSrc - RegWrite - - -
							end							
	{`MCC, 4'b101_0} :begin
							ALUctl = `_SRL_; // srli => SHIFT_RIGHT (funct3==3'b101)
							Ctl_out = 5'b1010_0;//0; // I-type    xxxi  rd, rs1,imm[11:0] ALUSrc - RegWrite - - -
							end
	default :begin
				ALUctl = 4'bx;
				Ctl_out = 5'bx000x;
				end
	endcase
end

endmodule
