ASM = nasm
QEMU = qemu-system-x86_64
SRC = boot.asm
BIN = boot.bin

all: $(BIN)

$(BIN): $(SRC)
	$(ASM) -f bin $< -o $@
	dd if=./message.txt bs=511 count=1 conv=sync >> $@
	printf '\0' >> $@

run: $(BIN)
	$(QEMU) -drive format=raw,file=$(BIN)

clean:
	rm -f $(BIN)

.PHONY: all run clean
