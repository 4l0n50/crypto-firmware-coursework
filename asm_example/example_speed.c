#include <stdio.h>
#include "../common/ecsw.h"

extern int power(int x, int e);

int main(void)
{
  unsigned int oldcount, newcount;

  setup();

  output("\n============ IGNORE OUTPUT BEFORE THIS LINE ============\n");
  
  oldcount = performance_count();
    int a = power(3, 5); 
  newcount = performance_count()-oldcount;

  unsigned char buffer[32];
  sprintf(buffer, "Cost: %d", newcount);
  output(buffer);

  teardown();
  
  return 0;
}
