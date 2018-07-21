# x86_64 Assembly Tic Tac Toe
> This project will **only** run on x86_64/AMD64 Linux versions.

A Tic Tac Toe version that operates on a **18 bit** grid data structure, written in assembly and C.

## About

Just recently I finished reading Jeff Duntemann's "Assembly Language Step-by-Step: Programming with Linux" book, a wonderful introduction to the Intel IA32 assembly language. I figured, writing a memory optimized version of Tic Tac Toe would be a great way to practice my newly acquired skills, as well as getting introduced to the newer x86_64 assembly language.

The core of the game has been written in assembly, which exposes gcc C compatible functions functions to set, read and evaluate the 3x3 Tic Tac Toe grid. Terminal IO and grid drawing is done in C, as the compiler likely generates more optimized code than I would If I were to write those features in assembly.

## Obtaining a local copy

To obtain a local copy of the repository, simply clone it using git:

```
$ git clone https://github.com/CTXz/x86_64-Assembly-Tic-Tac-Toe.git
```

Alternatively, the repository may be downloaded as a zip.

## Build and run

The following software must be available to successfully build an executable:

- GCC Linux x86_64
- NASM
- make

The repository contains a makefile that offers the following targets:

|Target                         |Description                                                        |
|-------------------------------|-------------------------------------------------------------------|
|all (aka `make` without target)|Builds the Tic Tac Toe executable.                                 |
|debug                          |Builds the Tic Tac Toe executable with the gcc and NASM `-g` flag. |
|clean                          |Removes any object code and binary executables in the project repo.|    

To build the `all` target, simply run:

```
$ make
```

To build another target, simply provide it as a argument:

```
$ make TARGET
```

`all` and `debug` will produce a binary executable called `ttt` which can be executed as it follows:
```
$ ./ttt
```


## The Grid

So how exactly does the grid operate on 18 bits?

A 3x3 tic-tac-toe grid consist of a total of 9 fields, where each field can maintain a total of three different states at a time:

- Empty
- Circle
- Cross

The least required amount of bits to display three different states is two. As a result, we can create a very primitive 2 bit data structure that represents a single tic-tac-toe field:

|          |LOW - 0|HIGH - 1|
|----------|-------|--------|
|Lower Bit |Empty  |Filled  |
|Higher Bit|Circle |Cross   |

The following table represents all possible bit pairs:

|Bit Pair|Represented Field                    |
|--------|-------------------------------------|
|00      |Empty                                |
|10      |Empty (This state should never occur)|
|01      |Circle                               |
|11      |Cross                                |

The low/right bit defines whether the field is empty or not.
The left/hight bit defines whether the field is filled with a cross or circle

Using a primitive data structure as such, we may create a 1 dimensional 18 bit wide tic-tac-toe grid. The lowest two bits are mapped to the top left field and the highest two bits are mapped to the bottom right field.

The following 18 bit data structure:

```
010111001111010011
```

Would translate into the following 2d grid:

```
X| |O
X|X|
X|O|O
```

As, x86_64 CPUs are only able to allocate 8, 16, 32 and 64 bits of memory at a time, the Tic Tac Toe field is technically running on 32 bits of reserved memory, however, only 20 bits are actively used. The remaining 12 bits can theoretically be used to store additional data.

## Setting and reading the grid

The code makes heavy use of "bit masks" and bitwise operations. To understand how fields are set and and read, a understanding of the **OR** and **AND** bitwise operators should be established. Further, one should understand how **bit shifts** and **rotations** work as those are frequently utilized during grid evaluation.

- To understand how a field is set, see the reference for the [set_field](docs/set_field.md) procedure.
- To understand how the current state of a field is obtained, see the reference for the [get_field](docs/get_field.md) procedure.
- To understand how the grid is evaluated for victory, see the [eval_grid](docs/eval_grid.md) reference.

### Reference

Source Files located in `src/`:

|File    |Description                                                          |
|--------|---------------------------------------------------------------------|
|core.asm|Core procedures written in assembly (ie. grid setting and reading)   |
|core.h  |A C interface for global procedures exposed by core.asm              |
|main.c  |Game code that utilizes functions exposed by the assembly core module|

Assembly Reference:

- [init_grid](init_grid.md)
- [eval_grid](eval_grid.md)
- [set_field](set_field.md)
- [get_field](get_field.md)
