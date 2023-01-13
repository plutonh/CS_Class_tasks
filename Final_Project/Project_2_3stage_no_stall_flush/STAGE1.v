`timescale 1ns / 1ps
module STAGE1(
	input clk, rst, //stall,
	input Ctl_RegWrite_in, 
	input [4:0] WriteReg_in,
	input [31:0] WriteData_in,
	
	output Ctl_ALUSrc, Ctl_MemtoReg, Ctl_RegWrite, Ctl_MemWrite, Ctl_Branch1, //Ctl_Branch0,
	output[3:0] ALUctl,
	output [4:0] Rd_out, 
	output [31:0] ReadData1_out, ReadData2_out, 
	output [31:0] Immediate_out,
	output [7:0]  PC4_out
	
    );
//8.559ns

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
//PC
wire [7:0] PC_next;
reg [7:0] PC;
always @(posedge clk) begin
	if(rst)
		PC <= 8'hff; //rst가 끝나면 overflow와 함께 시작한다.
	else
		PC <= PC_next;
end


wire [31:0] instr;
iMEM IF(
.clk(clk),
.PC(PC_next),
.Instruction_out(instr)
);


InDecode ID(
.clk(clk), .rst(rst),
.PC_in(PC),
.Ctl_RegWrite_in(Ctl_RegWrite_in),	//from WB
// control signal out
.Ctl_ALUSrc_out(Ctl_ALUSrc), 
.Ctl_MemtoReg_out(Ctl_MemtoReg), 
.Ctl_RegWrite_out(Ctl_RegWrite), 
.Ctl_MemWrite_out(Ctl_MemWrite), 
.Ctl_Branch1_out(Ctl_Branch1), 
.ALUctl_out(ALUctl),

.WriteReg_in(WriteReg_in), //reg주소 5bit = 32개의 주소
.WriteData(WriteData_in),
.instruction_in(instr), 
.Rd_out(Rd_out),
.ReadData1_out(ReadData1_out), .ReadData2_out(ReadData2_out), 
.Immediate_out(Immediate_out),
.PC4_out(PC4_out),
.PC_next(PC_next)
);

endmodule
