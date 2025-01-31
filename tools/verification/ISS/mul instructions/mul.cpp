//Program for the MUL opcode
//Program to multiply two 64 bit signed numbers and store the lower 64 bits of the result in destination.
#include <stdio.h>

void mul(int rd, int rs1, int rs2)
{
	int64_t numrs1;
	int64_t numrs2;
	int128_t numrd;

	numrs1 = bin2dec(Rreg[rs1]);
	numrs2 = bin2dec(Rreg[rs2]);
	numrd = numrs2 * numrs1;
	std::cout << "MUL TAKEN\n";

	/*printf("%d\n",numrs1 );
	printf("%d\n",numrs2 );
	printf("%ld\n",numrd );*/

	dec2bin128('L',Rreg[rd],numrd);
	
	/*printf("MUL\n");
	printreg(rs1);
	printreg(rs2);
	printreg(rd);*/
}
