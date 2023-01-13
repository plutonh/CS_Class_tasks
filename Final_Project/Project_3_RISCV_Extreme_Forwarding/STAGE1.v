`timescale 1ns / 1ps
module STAGE1(
	input clk, rst, 
	input Ctl_RegWrite_in, 
	input [4:0] WriteReg_in,
	input [31:0] WriteData_in, ALUresult_in,
	
	output Ctl_ALUSrc, Ctl_MemtoReg, Ctl_RegWrite, Ctl_MemWrite, Ctl_Branch1, //Ctl_Branch0,
	output[3:0] ALUctl,
	output [1:0] EXE_forwarding_out,
	output [4:0] Rd_out, 
	output [31:0] ReadData1_out, ReadData2_out, 
	output [31:0] Immediate_out,
	output [7:0]  PC4_out,
	output NOS
    );
//10.451ns

/* beq, bne만 쓸 거면 btb불필요
wire [7:0] PC_UC, PC_CB, PC;
wire flush;
Branch_Target_Buffer BTB(
.clk(clk), .rst(rst),
.PC_UC(PC_UC),
.PC_CB(PC_CB),
.taken(taken),
.PC_out(PC), 
.flush(flush)
);	
*/

////////////////////////////////////////////////////////
wire [7:0] PC_next;
wire [31:0] instr;
wire NOP;
iMEM IF(
.PC(PC_next),
.Instruction_out(instr)
);

//IF/ID reg
reg [31:0] ID_instr;
always @(posedge clk) begin
		ID_instr <= (NOP)? 32'bx_00000_00000_xx : instr;	
//만약 NOP일 경우 ld x0, ?(?)를 수행한다. x0은 NOP를 발생시키지 않는다.
end
///////////////////////////////////////////////////////////////////////////////////

Hazard_detection_unit Hazard(
.ID_Ctl_MemRead_in(~|ID_instr[6:2]),	//opcode가 00000이면 load
.ID_Rd(ID_instr[11:7]), 
.IF_Rs1(instr[19:15]), .IF_Rs2(instr[24:20]),
.inst_type({instr[6], instr[3:2]}),
.NOP_out(NOP)
    );

///////////////////////////////////////////////////////////////////////////////////
InDecode ID(
.clk(clk), .rst(rst), .NOP(NOP),
.Ctl_RegWrite_in(Ctl_RegWrite_in),	//from WB
// control signal out
.Ctl_ALUSrc_out(Ctl_ALUSrc), 
.Ctl_MemtoReg_out(Ctl_MemtoReg), 
.Ctl_RegWrite_out(Ctl_RegWrite), 
.Ctl_MemWrite_out(Ctl_MemWrite), 
.Ctl_Branch1_out(Ctl_Branch1), 
.ALUctl_out(ALUctl),
.EXE_forwarding_out(EXE_forwarding_out),

.WriteReg_in(WriteReg_in), //reg주소 5bit = 32개의 주소
.WriteData(WriteData_in),
.instruction_in(ID_instr), 
.ALUresult_in(ALUresult_in),
.Rd_out(Rd_out),
.ReadData1_out(ReadData1_out), .ReadData2_out(ReadData2_out), 
.Immediate_out(Immediate_out),
.PC4_out(PC4_out),
.PC_next(PC_next),
.NOS(NOS)
);

endmodule
