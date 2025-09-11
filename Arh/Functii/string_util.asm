; =============================================================================
;   Functia: read_line_from_buffer
; =============================================================================
;   SCOP:
;       Copiaza un sir de caractere dintr-un buffer sursa intr-unul destinatie,
;       pana la intalnirea caracterului newline (0Ah). Adauga un terminator
;       nul (0) la finalul sirului destinatie.
;
;   INTRARE (Input):
;       ESI: Pointer (adresa) la buffer-ul sursa.
;       EDI: Pointer (adresa) la buffer-ul destinatie.
;
;   IESIRE (Output):
;       EDI: Pointer-ul este mutat la finalul sirului copiat (dupa terminatorul nul).
;       ESI: Pointer-ul este mutat la caracterul de dupa newline in sursa.
; =============================================================================
read_line_from_buffer:
.loop:
    mov al, [esi]
    cmp al, 0Ah             ; Compara cu newline
    je .end
    mov [edi], al           ; Copiaza caracterul
    inc esi
    inc edi
    jmp .loop
.end:
    mov byte [edi], 0       ; Adauga terminatorul nul
    inc edi                 ; Muta pointerul dupa terminator
    inc esi                 ; Muta pointerul sursa dupa newline
    ret

; =============================================================================
;   Functia: string_length
; =============================================================================
;   SCOP:
;       Calculeaza lungimea unui sir de caractere terminat prin nul.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului.
;
;   IESIRE (Output):
;       ECX: Lungimea sirului (numarul de caractere, fara terminator).
; =============================================================================
string_length:
    xor ecx, ecx
.loop:
    mov al, [esi+ecx]       ; Acceseaza caracterul la adresa ESI + offset ECX
    cmp al, 0
    je .end
    inc ecx
    jmp .loop
.end:
    ret