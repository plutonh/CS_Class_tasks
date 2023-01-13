`timescale 1ns / 1ps

module WB(
// control signal
input Ctl_RegWrite_in, Ctl_MemtoReg_in,
output reg Ctl_RegWrite_out,

input	jal_in, jalr_in,
input	[31:0] PC_in,

input [ 4:0] Rd_in,
input [31:0] ReadDatafromMem_in, ALUresult_in,

output reg [ 4:0] Rd_out,
output reg [31:0] WriteDatatoReg_out
);


//조합 논리회로
/*
always @(*) begin
	//jump면 PC+4를 x1에 저장
	if (jal_in || jalr_in) // 문제
		WriteDatatoReg_out = PC_in + 4;
	else
		WriteDatatoReg_out = (Ctl_MemtoReg_in) ? ReadDatafromMem_in : ALUresult_in;
end
assign Rd_out = Rd_in;
assign Ctl_RegWrite_out = Ctl_RegWrite_in;
*/

always @(*) begin
		Rd_out <= Rd_in;
		Ctl_RegWrite_out <= Ctl_RegWrite_in;
		WriteDatatoReg_out <= (Ctl_MemtoReg_in == 1) ? ReadDatafromMem_in : ALUresult_in;
		if(Ctl_MemtoReg_in)	WriteDatatoReg_out <= ReadDatafromMem_in;
		else if(jalr_in || jal_in)	WriteDatatoReg_out <= PC_in + 4;
		else WriteDatatoReg_out <= ALUresult_in;
	end 
	
endmodule


