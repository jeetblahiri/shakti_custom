#include <stdio.h>
#include<iostream>
#include<string>
void bge(int rs1 , int rs2 , int * imm)
{

	int imm64[64];
	int64_t numrs1,numrs2,numimm64;
	int i = 0;
	int PC1 = PC;
	
	numrs1 = bin2dec(Rreg[rs1]);
	numrs2 = bin2dec(Rreg[rs2]);
	//printf("%d  %d\n", numrs1, numrs2);
	fileprintreg();
	if(numrs1 >= numrs2)
	{
		imm64[63] = 0;
		for (i= 0; i < 12; ++i)
		{
			imm64[62-i] = imm[11-i];
		}
		i = 0;
		while(i < 51)
		{
			imm64[i] = imm[0];
			i++;
		}
		
		numimm64 = bin2dec(imm64);
		int64_t decre = numimm64/4;
		std::cout << "BGE TAKEN\n";
		i=1;
		if(decre < 0)
		{
			if(decre*(-1) < (PC))
			{
				PC += decre-1;
				std::cout << "REVERSE BRANCH TAKEN" << "\n";
				int j = 1;
				fclose(assins);
				assins = fopen("ISS/input.hex","r");
				while(j <= PC) {
				fgets(line,sizeof(line),assins);
				j++;
			} }
			else {
			std::cout << "Illegal BGE Value";
			exit(1);
			}
		}
		else if(decre > 0)
		{
			PC += decre-1;
			std::cout << "FORWARD BRANCH TAKEN\n";
			std::cout << PC << "\n";	
			while(i<decre)
			{
				PC1++;
				//std::cout << PC1 << "\n";
				fgets(line,sizeof(line),assins);
				addq(line,PC1,data);
				if(PC1 > 1024)
				{
					delq(data);
				}
				i++;
			}
		}
	}
	std::cout << "BGE NOT TAKEN\n";
	//printreg(30);
	//printreg(31);
}
