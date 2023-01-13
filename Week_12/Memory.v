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

input Zero_in,	//checking branch 
input [31:0] Write_Data_in, ALUresult_in, PCimm_in, PC_in,
output PCSrc_out, //flush signal

output reg [31:0] Read_Data_out, ALUresult_out,
output reg [31:0] PC_out, 
output [31:0] PC_branch_out //branch_target_address
   );
reg [31:0] mem [127:0]; //32bit register 128lines creation


wire branch;
or(branch, Zero_in, jal_in, jalr_in);
and(PCSrc_out, Ctl_Branch_in, branch);
assign PC_branch_out = (jalr_in) ? ALUresult_in : PCimm_in;


//DataMemory
reg [31:0] Read_Data;
always @(Ctl_MemRead_in or ALUresult_in) begin
	if (Ctl_MemRead_in && ~Ctl_MemWrite_in) 
		Read_Data = mem[ALUresult_in];
end


integer i;
always @(posedge clk, posedge reset) begin  
	if(reset) begin
		for(i=0;i<128;i=i+1)
			mem[i] <= 32'b0;
		mem[22] <= 12;
		Read_Data <=0;
	end
	if(Ctl_MemWrite_in)
		mem[ALUresult_in] <= Write_Data_in;
end



// MEM/WB reg
always@(posedge clk) begin
	Ctl_MemtoReg_out 	<= (reset) ? 0 : Ctl_MemtoReg_in;
	Ctl_RegWrite_out 	<= (reset) ? 0 : Ctl_RegWrite_in;
	jal_out				<= (reset) ? 0 : jal_in;
	jalr_out				<= (reset) ? 0 : jalr_in;
	
	Read_Data_out		<= (reset) ? 0 : Read_Data;
	Rd_out 				<= (reset) ? 0 : Rd_in;
	ALUresult_out 		<= (reset) ? 0 : ALUresult_in;
	PC_out				<= (reset) ? 0 : PC_in;
	
end

endmodule