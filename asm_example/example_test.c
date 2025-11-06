#include <stdio.h>
#include "../common/ecsw.h"

extern int power(int x, int e);

int main(void)
{
  setup(ECSW_TEST);

  output("\n============ IGNORE OUTPUT BEFORE THIS LINE ============\n");
  
  int a = power(3, 5); 

 
  char buffer[32];
  sprintf(buffer, "Output %d", a);

  output(buffer);

  teardown();

  return 0;
}
