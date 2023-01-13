module WB(
// control signal
input Ctl_RegWrite_in, Ctl_MemtoReg_in,
output Ctl_RegWrite_out,

input	jal_in, jalr_in,
input	[31:0] PC_in,

input [ 4:0] Rd_in,
input [31:0] ReadDatafromMem_in, ALUresult_in,

output [ 4:0] Rd_out,
output reg [31:0] WriteDatatoReg_out
);

always @(*) begin
	// if jump, store PC+4 to x1
	if (jal_in | jalr_in)
		WriteDatatoReg_out = PC_in+4;
	else
		WriteDatatoReg_out = (Ctl_MemtoReg_in) ? ReadDatafromMem_in : ALUresult_in;
end
assign Rd_out = Rd_in;
assign Ctl_RegWrite_out = Ctl_RegWrite_in;

endmodule