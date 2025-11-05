#include <stdio.h>
#include "poly1305.h"
#include "../common/ecsw.h"

#define INLEN 512

const unsigned char msg[INLEN];

unsigned char tag[POLY1305_BYTES];

unsigned char key[POLY1305_KEYBYTES] = {
  0x57, 0x6c, 0x7c, 0x77, 0x6a, 0xc2, 0x93, 0xc6, 0x78, 0x3a, 0x4a, 0x48, 0xc9, 0x45, 0x20, 0x36};

int main(void)
{
  char outstr[128];
  unsigned long long oldcount, newcount;


  setup();

  output("\n============ IGNORE OUTPUT BEFORE THIS LINE ============\n");

  oldcount = performance_count();
  crypto_onetimeauth_poly1305(tag,msg,INLEN,key);
  newcount = performance_count()-oldcount;

  sprintf(outstr, "\n%s for %d bytes: %u",
  performance_count_unit(), INLEN, (unsigned) newcount);

  output(outstr);

  teardown();
  return 0;
}
