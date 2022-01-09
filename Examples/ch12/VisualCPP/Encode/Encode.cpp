// ENCODE.CPP  

// This program copies and encodes a file. 

#include <iostream>
#include <fstream>
#include "translat.h"

using namespace std;

int mainx() 
{  
  const int BUFSIZE = 200;
  char buffer[BUFSIZE];
  unsigned int count;    // character count
  
  unsigned short encryptCode;
  cout << "Encryption code [0-255]? ";
  cin >> encryptCode;

  ifstream infile( "infile.txt", ios::binary );
  ofstream outfile( "outfile.txt", ios::binary );

  cout << "Reading INFILE.TXT and creating OUTFILE.TXT...\n";

  while (!infile.eof() )
  {
    infile.read(buffer, BUFSIZE );
    count = infile.gcount();
    TranslateBuffer(buffer, count, encryptCode);
    outfile.write(buffer, count);
  }

  return 0;
}
