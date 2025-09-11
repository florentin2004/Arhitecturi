SECTION .data
    ; ... (nume fisiere, constanta c) ...
    mesaj_valid   db "valid", 0
    len_valid     equ $ - mesaj_valid
    
    mesaj_invalid db "invalid", 0
    len_invalid   equ $ - mesaj_invalid