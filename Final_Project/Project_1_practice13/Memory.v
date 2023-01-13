`timescale 1ns / 1ps

module Memory(
input reset, clk,
// control signal
input Ctl_MemtoReg_in, Ctl_RegWrite_in, Ctl_MemRead_in, Ctl_MemWrite_in, Ctl_Branch_in,
output reg Ctl_MemtoReg_out, Ctl_RegWrite_out,

input [ 4:0] Rd_in,
output reg [ 4:0] Rd_out,

input	jal_in, jalr_in,
output reg jal_out, jalr_out,

input Zero_in,	//branch 판별
input [31:0] Write_Data_in, ALUresult_in, PCimm_in, PC_in,
output PCSrc_out, //flush 신호로 사용 가능

output reg [31:0] Read_Data_out, ALUresult_out,
output reg [31:0] PC_out, 
output [31:0] PC_branch_out //branch_target_address
   );
reg [31:0] D_RAM [0:1023]; //32bit register 128줄 생성                                      !!!!! 수정된 부분 !!!!!


wire branch;
or(branch, jalr_in, jal_in, Zero_in);
and(PCSrc_out, Ctl_Branch_in, branch);
assign PC_branch_out = (jalr_in) ? ALUresult_in : PCimm_in;


//DataMemory
initial begin
	$readmemh("../src/darksocv.ram.mem", D_RAM);
end

always @(posedge clk) begin
	if(Ctl_MemWrite_in)
		D_RAM[ALUresult_in[31:2]] <= Write_Data_in;
	if(reset)
		Read_Data_out <= 0;
	else
		Read_Data_out <= D_RAM[ALUresult_in[31:2]];
end



// MEM/WB reg
always@(posedge clk) begin
	Ctl_MemtoReg_out 	<= (reset) ? 0 : Ctl_MemtoReg_in;
	Ctl_RegWrite_out 	<= (reset) ? 0 : Ctl_RegWrite_in;
	jal_out				<= (reset) ? 0 : jal_in;
	jalr_out				<= (reset) ? 0 : jalr_in;
	
	Rd_out 				<= (reset) ? 0 : Rd_in;
	ALUresult_out 		<= (reset) ? 0 : ALUresult_in;
	PC_out				<= (reset) ? 0 : PC_in;
	
end

endmodule
