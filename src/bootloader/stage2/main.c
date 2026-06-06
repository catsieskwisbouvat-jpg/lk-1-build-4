#include "stdint.h"

void __cdecl cstart(uint16_t bootDrive)
{
    puts("Hello World from C!");
    for (;;);
}