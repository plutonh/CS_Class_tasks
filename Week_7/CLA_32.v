`timescale 1ns / 1ps

module CLA_32bit(a, b, c0, sum, Cout);

	input [31:0] a;
	input [31:0] b;
	input c0;
	output [31:0] sum;
	output Cout;

	wire [3:0] G;		
	wire [3:0] P;	
	wire [3:1] C;	
		
	CLALogic_32 CarryLookAhead(G[3:0], P[3:0], c0, C[3:1], Cout);

	CLA8 u0 (a[ 7: 0],b[ 7: 0],  c0, sum[ 7: 0],	G[0],	P[0]);
	CLA8 u1 (a[15: 8],b[15: 8],C[1], sum[15: 8],	G[1],	P[1]);
	CLA8 u2 (a[23:16],b[23:16],C[2], sum[23:16],	G[2],	P[2]);
	CLA8 u3 (a[31:24],b[31:24],C[3], sum[31:24],	G[3],	P[3]);
endmodule

module CLA8(A, B, Cin, Sum, G, P);
	input [7:0] A;
	input [7:0] B;
	input Cin;			
	output [7:0] Sum;
	output G;			
	output P;
		
	wire [7:0] g;		
	wire [7:0] p;
	wire [7:1] c;
		
	CLALogic_8 CarryLookAhead (g, p, Cin, c, G, P);
	GPFullAdder FA0 (A[0], B[0], Cin, 	g[0], p[0], Sum[0]);
	GPFullAdder FA1 (A[1], B[1], c[1], 	g[1], p[1], Sum[1]);
	GPFullAdder FA2 (A[2], B[2], c[2], 	g[2], p[2], Sum[2]);
	GPFullAdder FA3 (A[3], B[3], c[3], 	g[3], p[3], Sum[3]);
	GPFullAdder FA4 (A[4], B[4], c[4], 	g[4], p[4], Sum[4]);
	GPFullAdder FA5 (A[5], B[5], c[5], 	g[5], p[5], Sum[5]);
	GPFullAdder FA6 (A[6], B[6], c[6], 	g[6], p[6], Sum[6]);
	GPFullAdder FA7 (A[7], B[7], c[7], 	g[7], p[7], Sum[7]);

endmodule

module GPFullAdder(x, y, cin, g, p, Sum);
      input x;
      input y;
      input cin;		
      output g;		
      output p;		
      output Sum;

      assign g = x & y;				//g=x*y
      assign p = x | y;				//p=x+y
      assign Sum = x ^ y ^ cin;	//Sum=XOR(x, y, cin)
endmodule
  
  
module CLALogic_8 (g, p, Cin, c, G, P);
	input [7:0] g;
	input [7:0] p;
	input Cin;		
	output [7:1] c;	
	output P;		
	output G;		
		
	assign P = &p;		
	assign G =   g[7] | 
					(p[7] & g[6]) | 
					((&p[7:6]) & g[5]) | 
					((&p[7:5]) & g[4]) | 
					((&p[7:4]) & g[3]) | 
					((&p[7:3]) & g[2]) | 
					((&p[7:2]) & g[1]) | 
					((&p[7:1]) & g[0]);

	assign c[1] = g[0] | (p[0] & Cin);
	assign c[2] = g[1] | (p[1] & g[0]) | ((&p[1:0]) & Cin);
	assign c[3] = g[2] | (p[2] & g[1]) | ((&p[2:1]) & g[0]) | ((&p[2:0]) & Cin);
	assign c[4] = g[3] | (p[3] & g[2]) | ((&p[3:2]) & g[1]) | ((&p[3:1]) & g[0]) | ((&p[3:0]) & Cin);
	assign c[5] = g[4] | (p[4] & g[3]) | ((&p[4:3]) & g[2]) | ((&p[4:2]) & g[1]) | ((&p[4:1]) & g[0])| ((&p[4:0]) & Cin);
	assign c[6] = g[5] | (p[5] & g[4]) | ((&p[5:4]) & g[3]) | ((&p[5:3]) & g[2]) | ((&p[5:2]) & g[1])| ((&p[5:1]) & g[0]) | ((&p[5:0]) & Cin);
	assign c[7] = g[6] | (p[6] & g[5]) | ((&p[6:5]) & g[4]) | ((&p[6:4]) & g[3]) | ((&p[6:3]) & g[2])| ((&p[6:2]) & g[1]) | ((&p[6:1]) & g[0]) | ((&p[6:0]) & Cin);		
   
endmodule



module CLALogic_32 (G, P, c0, C, Cout);
	input [3:0] G;
	input [3:0] P;
	input c0;
	output [3:1] C;	
	output Cout;		
		
	assign C[1] = G[0] | (P[0] & c0);
	assign C[2] = G[1] | (P[1] & G[0]) | ((&P[1:0]) & c0);
	assign C[3] = G[2] | (P[2] & G[1]) | ((&P[2:1]) & G[0]) | ((&P[2:0]) & c0);
	assign Cout = G[3] | (P[3] & G[2]) | ((&P[3:2]) & G[1]) | ((&P[3:1]) & G[0]) | ((&P[3:0]) & c0);

endmodule