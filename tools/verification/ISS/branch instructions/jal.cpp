#include <stdio.h>

void jal (int rd  , int * imm){
	int i , imm64[64];
	int PC1 = PC;
	imm64[63]=0;
	for (i= 0; i <20 ; ++i)
	{
		imm64[62-i] = imm[19-i];
	}
	i = 0;
	while(i < 43)
	{
		imm64[i] = imm[0];
		i++;
	}
	int64_t decre = bin2dec(imm64)/4 ;
	int64_t tempPC = PC + decre-1;
	if(rd!=0)
	dec2bin(Rreg[rd], (PC)*4);
	fileprintreg();
	i=1;
	std::cout << "JAL TAKEN: " << "DECRE : " << decre << " TEMPPC: " << tempPC << " OldPC : " << PC << "\n"; 
	if(decre <= 0)
		{
		if(decre*(-1) < PC)
		{
			PC = tempPC;
			int j = 1;
			fclose(assins);
			assins = fopen("ISS/input.hex","r");
			while(j <= PC) {
			fgets(line,sizeof(line),assins);
			j++;
			}
		}
		else {
			std::cout << "ILLEGAL JAL JUMP VALUE - CHECK CODE" ;
			exit(1);
		} }
	else if(decre > 0)
		{
		PC = tempPC;
		//std::cout << PC << "\n";
		//std::cout << "INC: " << decre << "\n";	
			while(i<decre)
			{
				PC1++;
				//std::cout << PC1 << "\n";
				fgets(line,sizeof(line),assins);
				//std::cout << "HEX LINE IS: " << line;
				addq(line,PC1,data);
				if(PC1 > 1024)
				{
					delq(data);
				}
				i++;
			}
		}
	}

	//printreg(30);
	//printreg(31);

