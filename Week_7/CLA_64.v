`timescale 1ns / 1ps

module CLA64(a, b, Cin, sum, Cout);

		input [63:0] a;
		input [63:0] b;
		input Cin;
		output [63:0] sum;
		output Cout;

		wire [3:0] GG;		
		wire [3:0] PP;		
		wire [3:1] CC;		
		
		CLALogic CarryLookAhead(GG[3:0], PP[3:0], Cin, CC[3:1], Not_USED_GGG, Not_USED_PPP, Cout);

		// 8bit  A     	B       		Ci    	S   			G   		P 
		CLA16 u0 (a[15: 0],b[15: 0],	Cin, 	 sum[15: 0],	GG[0],	PP[0]);
		CLA16 u1 (a[31:16],b[31:16],	CC[1], sum[31:16],	GG[1],	PP[1]);
		CLA16 u2 (a[47:32],b[47:32],	CC[2], sum[47:32],	GG[2],	PP[2]);
		CLA16 u3 (a[63:48],b[63:48],	CC[3], sum[63:48],	GG[3],	PP[3]);
endmodule


module CLA16(a, b, Cin, sum, GG, PP, Cout);

		input [15:0] a;
		input [15:0] b;
		input Cin;
		output [15:0] sum;
		output GG, PP, Cout;

		wire [3:0] G;		
		wire [3:0] P;		
		wire [3:1] C;		
		
		CLALogic CarryLookAhead(G[3:0], P[3:0], Cin, C[3:1], GG, PP, Not_Used_Carry_Out);

		CLA4 u0 (a[ 3: 0],b[ 3: 0], Cin, sum[ 3: 0],	G[0],	P[0]);
		CLA4 u1 (a[ 7: 4],b[ 7: 4],C[1], sum[ 7: 4],	G[1],	P[1]);
		CLA4 u2 (a[11: 8],b[11: 8],C[2], sum[11: 8],	G[2],	P[2]);
		CLA4 u3 (a[15:12],b[15:12],C[3], sum[15:12],	G[3],	P[3]);
endmodule

module CLA4(A, B, Cin, Sum, G, P);
		input [3:0] A;
		input [3:0] B;
		input Cin;			
		output [3:0] Sum;
		output G;			
		output P;
		
		wire [3:0] g;		
		wire [3:0] p;
		wire [3:1] c;
		
		CLALogic CarryLookAhead (g[3:0], p[3:0], Cin, c[3:1], G, P, Not_Used_Carry_Out);
		GPFullAdder FA0 (A[0], B[0], Cin, 	g[0], p[0], Sum[0]);
		GPFullAdder FA1 (A[1], B[1], c[1], 	g[1], p[1], Sum[1]);
		GPFullAdder FA2 (A[2], B[2], c[2], 	g[2], p[2], Sum[2]);
		GPFullAdder FA3 (A[3], B[3], c[3], 	g[3], p[3], Sum[3]);

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

module CLALogic (G, P, Cin, C, GG, PP, Cout);
		input [3:0] G;
		input [3:0] P;
		input Cin;
		output [3:1] C;	
		output GG, PP, Cout;


		assign PP = &P;		
		assign GG = G[3] | (P[3] & G[2]) | ((&P[3:2]) & G[1]) | ((&P[3:1]) & G[0]);

		
		assign C[1] = G[0] | (P[0] & Cin);
		assign C[2] = G[1] | (P[1] & G[0]) | ((&P[1:0]) & Cin);
		assign C[3] = G[2] | (P[2] & G[1]) | ((&P[2:1]) & G[0]) | ((&P[2:0]) & Cin);
		assign Cout = G[3] | (P[3] & G[2]) | ((&P[3:2]) & G[1]) | ((&P[3:1]) & G[0]) | ((&P[3:0]) & Cin);
endmodule