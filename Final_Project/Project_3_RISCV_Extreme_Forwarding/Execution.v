`timescale 1ns / 1ps
//13.698ns
//ALU OPERATION
`define _AND_	4'b0000
`define _OR_	4'b0001
`define _ADD_	4'b0010
`define _SUB_	4'b0110
`define _BEQ_	4'b0111	
`define _BNE_	4'b1000	
`define _JAL_	4'b0011	
`define _JALR_	4'b0010	//ADD랑 코드 같음
`define _BLT_	4'b0111
`define _BGE_	4'b1011
`define _NOR_	4'b1100
`define _SLL_	4'b1001
`define _SRL_	4'b1010

module STAGE2(
input clk, rst, NOS,
// control signal
input Ctl_ALUSrc_in, Ctl_MemtoReg_in, Ctl_RegWrite_in, Ctl_Branch1_in, //Ctl_Branch0_in,
input [3:0] ALU_ctl_in,
input [1:0] EXE_forwarding_in,
input [ 4:0] Rd_in,
input [31:0] ReadData1_in, ReadData2_in, Immediate_in, WriteData_in,
input [7:0] PC4_in,

output reg Ctl_MemtoReg_out, Ctl_RegWrite_out, 

output reg [ 4:0] Rd_out,

//output taken,
output [31:0] ALUresult_out, MemWriteData_out//비동기여야 MEM/WB stage에서 write된다.
);


//jal, jalr은 MemtoReg=0, RegWrite=1이다. 따라서 ALUresult를 애초에 PC4로 맞춘다.
wire [31:0] ALUresult;
assign ALUresult_out = (Ctl_Branch1_in) ? PC4_in : ALUresult; 


//forwarding은 MEM stage에 대해서만 이루어지면 된다.
//x0은 항상 RegWrite=0이므로 Rd검사 불필요.->속도 향상
wire [31:0] ALU_input1 = (EXE_forwarding_in[0])? WriteData_in : ReadData1_in;
wire [31:0] MemWriteData = (EXE_forwarding_in[1]) ? WriteData_in : ReadData2_in;
assign MemWriteData_out = MemWriteData;
wire [31:0] ALU_input2 = (Ctl_ALUSrc_in) ? Immediate_in : MemWriteData;

ALU B1(.ALU_ctl(ALU_ctl_in), .in1(ALU_input1), .in2(ALU_input2), .out(ALUresult));

always @(posedge clk) begin
	Ctl_MemtoReg_out <= (NOS) ? 1'b0 : Ctl_MemtoReg_in;
	Ctl_RegWrite_out <= (NOS) ? 1'b0 : Ctl_RegWrite_in;
	Rd_out <= Rd_in;
end

endmodule

//////////////////////////////////////////////////////////////////////////////////
module ALU(
input [3:0] ALU_ctl,
input signed [31:0] in1, in2,
output reg [31:0] out
//output reg taken
);

//연산의 종류와, 연산하는 범위를 줄이면 속도를 향상시킬 수 있음.
always @(*) begin
case (ALU_ctl)
	`_AND_	: out = in1 & in2; // and
//	`_OR_		: out = in1 | in2; // or
	`_ADD_	: 	begin
						out = in1 + in2; // add
					end
	`_SUB_	: 	begin
						out = in1 - in2; // sub
					end
	
/*	`_BEQ_	: begin
					//out = (in1 == in2) ? 32'b01 : 32'b00;	//beq 
						out = 32'bx;
						taken = (in1 == in2) ? 1'b1 : 1'b0;
					end
	`_BNE_	: out = (in1 != in2) ? 32'b01 : 32'b00;	//bne
	`_BLT_	: begin
					//out = (in1 < in2) ? 32'b01 : 32'b00; // blt (branch if less than)
						out = 32'bx;
						taken = (in1 < in2) ? 1'b1 : 1'b0;
					end
	`_BGE_	: begin
						//out = (in1 >= in2) ? 32'b01 : 32'b00; // bge (branch if greater equal)
						out = 32'bx;
						taken = (in1 >= in2) ? 1'b1 : 1'b0;
					end
*/	`_SLL_	: begin
						out = in1 << in2; // shift left
					end
	`_SRL_	: begin
						out = in1 >> in2; // shift right
					end
	default : begin
					out = 32'bx;
				end
endcase
end
//branch전용 연산기를 따로 만듦.
endmodule
