all: Test

Test: Test.asm
	nasm -g -f elf32 -o Test.o Test.asm
	ld -m elf_i386 -o Test Test.o
        
clean:
	@echo "Cleaning up..."
	rm Test
