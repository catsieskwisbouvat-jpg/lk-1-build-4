bits 16

section _ENTRY class=CODE

extern _cstart      ; Zorg dat deze naam exact matcht met je C-functie

global entry

entry:
    cli
    mov ax, ds
    mov ss, ax
    mov sp, 0x7C00  ; Gebruik een veilig adres voor de stack (bijv. 0x7C00)
    mov bp, sp      ; Zet bp gelijk aan sp

    xor dh, dh
    push dx
    call _cstart    ; Haal de extra underscore weg om te matchen met 'extern _cstart'

    cli
    hlt