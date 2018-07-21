ASM 			:= nasm
ASM_FLAGS := -f elf64 -F stabs

CC				:= gcc
CC_FLAGS  :=

LD_FLAGS  :=

all: ttt

debug: ttt_debug

clean:
	rm -f ttt src/*.o

ttt: src/core.o src/main.o
	$(CC) $(LD_FLAGS) src/core.o src/main.o -o ttt

ttt_debug: src/core_debug.o src/main_debug.o
	$(CC) $(LD_FLAGS) src/core_debug.o src/main_debug.o -o ttt

src/core.o:
	$(ASM) $(ASM_FLAGS) src/core.asm -o src/core.o

src/core_debug.o:
	$(ASM) $(ASM_FLAGS) -g src/core.asm -o src/core_debug.o

src/main.o:
	$(CC) $(CC_FLAGS) -c src/main.c -o src/main.o

src/main_debug.o:
	$(CC) $(CC_FLAGS) -g -c src/main.c -o src/main_debug.o
