OBJS = source.cpp

CC = g++

COMPILER_FLAGS = -w -g

LINKER_FLAGS = -lSDL2

OBJ_NAME = sdltest

all: nasm_loop.o $(OBJS) 
	$(CC) nasm_loop.o $(OBJS) $(COMPILER_FLAGS) $(LINKER_FLAGS) -o $(OBJ_NAME) 
	
	
nasm_loop.o: nasm_loop.asm
	nasm -f elf64 -g -o nasm_loop.o nasm_loop.asm
	
#c_sdl: $(OBJS) 
#	$(CC) $(OBJS) $(COMPILER_FLAGS) $(LINKER_FLAGS) -o $(OBJ_NAME) 

