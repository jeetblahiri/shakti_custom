#include <stdio.h>

void jalr(int rd , int rs1 , int * imm)
{
	int imm64[64];
	int i = 0;
	for (i= 0; i < 12; ++i)
	{
		imm64[63-i] = imm[11-i];
	}
	i = 0;


	while(i < 52)
	{
		imm64[i] = imm[0];
		i++;
	}

	int64_t immvalue;
	uint64_t rs1value;
	int64_t jumploc;
	int64_t decre;
	immvalue = bin2dec(imm64);
	rs1value = ubin2dec(Rreg[rs1]);
	jumploc = immvalue + (int64_t)rs1value;
	decre = jumploc/4;
	std::cout << "JALR TAKEN\n";
	std:: cout << "PC : " << PC << " IMM: " << immvalue << " Decre: " << decre << " Jumploc: " << jumploc << " RS1: " << rs1value << "\n";	
	//printf(" PC = %ld, immediate is = %ld, jumplocation is = %ld \n", PC, immvalue, decre);
	if(rd!=0)	
	dec2bin(Rreg[rd], (PC)*4);
	fileprintreg();
	i=1;
		while(PC<decre)
		{
			
			if(fgets(line,sizeof(line),assins)==NULL)	
			{
			std::cout << "ILLEGAL JUMP - CHECK CODE\n";
			exit(1);
			}
			addq(line,PC,data);
			if(PC > 1024)
				{
					delq(data);
				}
			PC++;
		}	
		if(PC > decre) 
		{
			int64_t j = 1;
			PC = decre;
			fclose(assins);
			assins = fopen("ISS/input.hex","r");
			if(decre > 0)
			{
			while(j <= PC)	
			{
			fgets(line,sizeof(line),assins);
			j++;
			}
			}
			else if(decre < 0)
			{
			std::cout << "ADDRESS CAN'T BE NEGATIVE - ILLEGAL\n";
			exit(1);
			}
		}
		
		
}
