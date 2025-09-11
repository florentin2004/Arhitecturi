gaseste_newline_in_buffer:
    ; ESI este deja setat de la string_to_integer
.loop_gnl:
    cmp byte [esi], 0Ah;   ; ' ' sau orice alt caracter
    je .found_gnl; 
    inc esi; 
    jmp .loop_gnl
.found_gnl:
    ret