`timescale 1ns / 1ps
//5ns
module Memory(
input clk, reset,
// control signal
input Ctl_MemWrite_in, //비동기

input [31:0] Write_Data_in, //비동기
input [31:0] ALUresult_in, //비동기

output reg [31:0] LoadData, ALUresult_out
   );
	

//DataMemory
reg [31:0] D_RAM [0:16383]; //31bit register 16384줄 생성 
//reg [31:0] D_RAM [0:9215]; //32bit register 9216줄 생성 
//reg [31:0] D_RAM [0:2048]; //32bit register 1024줄 생성 
initial begin
	$readmemh("../src/darksocv.ram.mem", D_RAM);
end

//모든 input data들이 비동기로 STAGE3시작 전에 주어졌으므로 STAGE3에서 MEM Write및 READ한다.
//BRAM의 in/out port는 각각 2개이며, 따라서 동시에 입출력 가능하다.

always @(posedge clk) begin
	LoadData <= D_RAM[ALUresult_in[31:2]];
	ALUresult_out <= ALUresult_in;
	if (~reset && Ctl_MemWrite_in) 
		D_RAM[ALUresult_in[31:2]] <= Write_Data_in;	
end


endmodule
