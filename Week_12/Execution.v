`timescale 1ns / 1ps

//ALU OPERATION
`define _AND_	4'b0000
`define _OR_	4'b0001
`define _ADD_	4'b0010
`define _SUB_	4'b0110
`define _BLT_	4'b0111
`define _BGE_	4'b1011
`define _NOR_	4'b1100
`define _SLL_	4'b1001
`define _SRL_	4'b1010


module Execution(
input clk, reset,
input flush, // control hazard 
// control signal
input Ctl_ALUSrc_in, Ctl_MemtoReg_in, Ctl_RegWrite_in,Ctl_MemRead_in, Ctl_MemWrite_in, Ctl_Branch_in, Ctl_ALUOpcode1_in, Ctl_ALUOpcode0_in,
output reg Ctl_MemtoReg_out, Ctl_RegWrite_out, Ctl_MemRead_out, Ctl_MemWrite_out, Ctl_Branch_out,

input [ 4:0] Rd_in,
output reg [ 4:0] Rd_out,
input jal_in, jalr_in,
output reg jal_out, jalr_out,

input [31:0] Immediate_in, ReadData1_in, ReadData2_in, PC_in,
input [31:0] ex_mem_data_in, wb_data_in,
input [ 6:0] inst30_in,
input [ 2:0] funct3_in,
input [ 1:0] ForwardA_in, ForwardB_in,
output reg Zero_out,

output reg [31:0] ALUresult_out, PCimm_out, ReadData2_out, PC_out
);


wire [3:0] ALU_ctl;
wire [31:0] ALUresult;



wire zero;

// 10 is ex_mem_reg_data, 01 is wb_mux_out_data, and others are 00 and just ReadData.
wire [31:0] ALU_input1 = (ForwardA_in == 2'b01) ? wb_data_in : (ForwardA_in == 2'b10) ? ex_mem_data_in : ReadData1_in;
wire [31:0] ForwardB_input = (ForwardB_in == 2'b01) ? wb_data_in : (ForwardB_in == 2'b10) ? ex_mem_data_in : ReadData2_in;
wire [31:0] ALU_input2 = (Ctl_ALUSrc_in) ? Immediate_in : ForwardB_input;

ALU_control B0 (.ALUop({Ctl_ALUOpcode1_in,Ctl_ALUOpcode0_in}), .inst30(inst30_in), .funct3(funct3_in), .ALU_ctl(ALU_ctl));
ALU B1 (.ALU_ctl(ALU_ctl), .in1(ALU_input1), .in2(ALU_input2), .out(ALUresult), .zero(zero));

always@(posedge clk, posedge reset) begin
	Ctl_MemtoReg_out	<= (reset||flush) ? 0 : Ctl_MemtoReg_in;
	Ctl_RegWrite_out	<= (reset||flush) ? 0 : Ctl_RegWrite_in;
	Ctl_MemRead_out	<= (reset||flush) ? 0 : Ctl_MemRead_in;
	Ctl_MemWrite_out	<= (reset||flush) ? 0 : Ctl_MemWrite_in;
	Ctl_Branch_out		<= (reset||flush) ? 0 : Ctl_Branch_in;

	PC_out	<= (reset) ? 0 : PC_in;
	jalr_out	<= (reset||flush) ? 0 : jal_in;
	jal_out	<= (reset||flush) ? 0 : jalr_in;

	Rd_out			<= (reset) ? 0 : Rd_in;
	PCimm_out		<= (reset) ? 0 : PC_in + (Immediate_in<<1);
	ReadData2_out	<= (reset) ? 0 : ForwardB_input;
	ALUresult_out	<= (reset) ? 0 : ALUresult;
	Zero_out			<= (reset) ? 0 : zero;

end
endmodule
//////////////////////////////////////////////////////////////////////////////////
module ALU_control(
input [1:0] ALUop,
input inst30,
input [2:0] funct3,
output reg [3:0] ALU_ctl
);

//ALU_ctl : OPERATION
//4'b0000 : and ==>ReadData1&ReadData2
//4'b0001 : or ==>ReadData1|ReadData2
//4'b0010 : add ==>ReadData1+ReadData2(Immediate_in)
//4'b0110 : sub ==>ReadData1-ReadData2
//4'b0111 : blt (branch if less than)
//4'b1011 : bge (branch if greater equal)     // Blt,bge is set to out=0 to make it zero=1.
//4'b1100 : nor ==> ~(ReadData1|ReadData2)
//4'b1001 : shift left
//4'b1010 : shift right

always @(*) begin
casex ({ALUop,funct3,inst30})
	6'b00_xxx_x : ALU_ctl = `_ADD_; // lb, lh, lw, sb, sh, sw => ADDITION
	6'b01_00x_x : ALU_ctl = `_SUB_; // beq, bne => SUBTRACT (funct3==3'b000) || (funct3==3'b001)
	6'b01_100_x : ALU_ctl = `_BLT_; // blt => BLT(branch if less than) (funct3==3'b100)
	6'b01_101_x : ALU_ctl = `_BGE_; // bge => BGE(branch if greater than) (funct3==3'b101)
	6'b10_000_0 : ALU_ctl = `_ADD_; // add => ADDITION (funct3==3'b000 && funct7==7'b0000000)
	6'b10_000_1 : ALU_ctl = `_SUB_; // sub => SUBTRACT (funct3==3'b000 && funct7==7'b0100000)
	6'b1x_111_0 : ALU_ctl = `_AND_; // and => AND (funct3==3'b111 && ALUop==1x)
	6'b1x_110_0 : ALU_ctl = `_OR_;  // or => OR (funct3==3'b110 && ALUop=1x)
	6'b00_001_0 : ALU_ctl = `_SLL_; // sll => SHIFT_LEFT (funct3==3'b001)
	6'b00_101_0 : ALU_ctl = `_SRL_; // srl => SHIFT_RIGHT (funct3==3'b101)
	6'b11_000_x : ALU_ctl = `_ADD_; // addi, jalr => ADDITION (funct3==3'b000)
	6'b11_001_0 : ALU_ctl = `_SLL_; // slli => SHIFT_LEFT (funct3==3'b001)
	6'b11_101_0 : ALU_ctl = `_SRL_; // srli => SHIFT_RIGHT (funct3==3'b101)
	default : ALU_ctl = 4'bx;
endcase
end


endmodule

//////////////////////////////////////////////////////////////////////////////////
module ALU(
input [3:0] ALU_ctl,
input [31:0] in1, in2,
output reg [31:0] out,
output zero
);

always @(*) begin
case (ALU_ctl)
	`_AND_	: out = in1 & in2; // and
	`_OR_		: out = in1 | in2; // or
	`_ADD_	: out = in1 + in2; // add
	`_SUB_	: out = in1 - in2; // sub
	`_BLT_	: out = in1 < in2 ? 1 : 0; // blt (branch if less than)
	`_BGE_	: out = (in1 >= in2) ? 1 : 0; // bge (branch if greater equal) - Blt,bge is set to out=0 to make it zero=1.
	`_NOR_	: out = ~(in1 | in2); // nor
	`_SLL_	: out = in1 << in2; // shift left
	`_SRL_: out = in1 >> in2; // shift right
	default : out = 32'bx;
endcaseend

assign zero = ~|out; //(ALU_ctl == 4'b0110) / Beq,bne can be checked with zero
//(ALU_ctl == 4'b0111&1000) /blt,bge ==> In mem stage, decide whether to branch with zero and branch signal.
endmodule