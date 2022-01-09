
#include <string.h>

extern "C" void MakeString()
{
	char firstName[20];
	strcpy(firstName,"tim");
}

void main()
{
	MakeString();
}