ASM = nasm
QEMU = qemu-system-x86_64
SRC = boot.asm
BIN = boot.bin

all: $(BIN)

$(BIN): $(SRC)
	$(ASM) -f bin $< -o $@

run: $(BIN)
	$(QEMU) -drive format=raw,file=$(BIN)

clean:
	rm -f $(BIN)

.PHONY: all run clean
