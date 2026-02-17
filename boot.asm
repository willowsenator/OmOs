ORG 0X7c00           ; BIOS loads the boot sector here
BITS 16              ; Real mode code

start:
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