# init_grid
> Source: [core.asm](https://github.com/CTXz/x86_64-Assembly-Tic-Tac-Toe/blob/master/src/core.asm#L111)

## Description

Initializes/Empties the tic-tac-toe field by overwriting its allocated memory with zeros.

init_grid **must** be called before any other core procedure, else the allocated memory may be filled with garbage and procedures will result in undefined behavior.

## C Call
```C
void init_grid();
```

## C Example

```C
#include "core.h"

int main()
{
    init_grid();
    // Handle grid here...
    return 0;
}
```

## Assembly Example

```asm
main:
call init_grid
```

## Procedure Diagram

The diagram may be viewed online [here](https://www.lucidchart.com/documents/view/35b1d137-33df-4bc6-87dc-e6aa1f333ded)

![diagram](img/init_grid.png)
