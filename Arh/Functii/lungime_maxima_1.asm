; =============================================================================
;   Functia: get_max_consecutive_ones
; =============================================================================
;   SCOP:
;       Calculeaza lungimea celei mai lungi secvente de caractere '1'
;       dintr-un sir terminat prin nul.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului.
;
;   IESIRE (Output):
;       EAX: Lungimea maxima gasita.
; =============================================================================
get_max_consecutive_ones:
    xor eax, eax            ; EAX = max_len (rezultatul final)
    xor edx, edx            ; EDX = current_len (lungimea secventei curente)

.loop:
    mov bl, [esi]           ; Luam caracterul curent
    cmp bl, 0
    je .end_of_string       ; Daca am ajuns la final, gata

    cmp bl, '1'             ; Comparam cu caracterul '1'
    je .is_a_one

.is_a_zero:
    ; Am gasit un '0' (sau alt caracter)
    ; Verificam daca secventa curenta era mai mare decat maximul
    cmp eax, edx
    jge .reset_current      ; Daca max_len >= current_len, doar resetam
    mov eax, edx            ; Altfel, actualizam max_len
.reset_current:
    xor edx, edx            ; Resetam contorul curent
    jmp .continue_loop

.is_a_one:
    inc edx                 ; Incrementam contorul secventei curente

.continue_loop:
    inc esi
    jmp .loop

.end_of_string:
    ; Trebuie sa facem o ultima verificare, in caz ca sirul se termina cu '1'
    cmp eax, edx
    jge .done
    mov eax, edx
.done:
    ret