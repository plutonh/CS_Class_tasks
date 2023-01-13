`timescale 1ns / 1ps
//5ns
module Memory(
input clk, reset,
// control signal
input Ctl_MemWrite_in, //�񵿱�

input [31:0] Write_Data_in, //�񵿱�
input [31:0] ALUresult_in, //�񵿱�

output reg [31:0] LoadData, 
output reg [31:0] ALUresult_out
   );
	

//DataMemory
reg [31:0] D_RAM [0:16383]; //31bit register 16384�� ���� 
//reg [31:0] D_RAM [9215:0]; //32bit register 9216�� ���� 
//reg [31:0] D_RAM [1023:0]; //32bit register 1024�� ���� 
initial begin
	$readmemh("../src/darksocv.ram.mem", D_RAM);
end

//��� input data���� �񵿱�� STAGE3���� ���� �־������Ƿ� STAGE3���� MEM Write�� READ�Ѵ�.
//BRAM�� in/out port�� ���� 2���̸�, ���� ���ÿ� ����� �����ϴ�.

always @(posedge clk) begin
	if (~reset && Ctl_MemWrite_in) 
		D_RAM[ALUresult_in[31:2]] <= Write_Data_in;
	
	LoadData <= D_RAM[ALUresult_in[31:2]];
end

//WB
always @(posedge clk) begin
	ALUresult_out <= ALUresult_in;
end

endmodule
