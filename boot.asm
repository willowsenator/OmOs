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
    ; Print the null-terminated string at `message`
    mov si, message
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
    mov bl, 0x03 ;Green color
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

message: db 'Hello, OmOs!', 0
times 510-($-$$) db 0 ; Pad to 510 bytes
dw 0xaa55             ; Boot signature