ORG 0                ; Origin address for the bootloader
BITS 16              ; Real mode code

_start:
    jmp short start     ; Jump to the start of the bootloader code
    nop                ; Padding to ensure the jump instruction is 3 bytes long 

times 33 db 0          ; For not corrupting the bootloader

start:
    jmp 0x7c0: step2     ; Jump to the code at 0x7c0, where the bootloader is loaded in memory

step2:
    cli                 ; Clear interrupts
    mov ax, 0x7c0       ; Load the segment of the bootloader
    mov ds, ax          ; Set DS to the segment of the bootloader
    mov es, ax          ; Set ES to the segment of the bootloader
    mov ax, 0x00        ; Load 0 into AX
    mov ss, ax          ; Set SS to 0
    mov sp, 0x7c00     ; Set SP to the top of the bootloader

    sti                 ; Enable interrupts

    ; Read sector 2 from disk into memory using BIOS INT 0x13 AH=02h
    mov ah, 0x02      ; BIOS function: read sectors
    mov al, 1         ; Number of sectors to read
    mov ch, 0         ; Cylinder number (0 = first cylinder)
    mov cl, 2         ; Sector number (2 = second sector, 1-based)
    mov dh, 0         ; Head number (0 = first head)
    ; DL is already set by BIOS to the boot drive number
    mov bx, buffer    ; ES:BX = destination address for the read data
    int 0x13          ; Call BIOS disk interrupt
    jc error          ; Jump to error handler if carry flag is set (read failed)

    ; Read succeeded — print the data loaded from sector 2
    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    lodsb             ; AL = next character, SI++
    cmp al, 0
    je .done
    call print_char
    jmp print
.done:
    ret

print_char:
    mov ah, 0x09 ;Write char with color
    mov bh, 0 ;Page number
    mov bl, 0x03 ; Color: cyan
    mov cx, 1
    int 0x10

    mov ah, 0x03 ;Get cursor position
    mov bh, 0
    int 0x10

    inc dl ;Move cursor to the right

    mov ah, 0x02 ;Set cursor position
    mov bh, 0
    int 0x10
    ret

error_message: db 'Failed to read disk', 0
times 510-($-$$) db 0 ; Pad to 510 bytes
dw 0xaa55             ; Boot signature

buffer: ; Destination for data read from disk (past the 512-byte boot sector)