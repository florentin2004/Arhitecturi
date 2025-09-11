; =============================================================================
;   Functia: parse_vector_from_buffer
; =============================================================================
;   SCOP:
;       Parcurge un buffer de text, converteste numerele separate prin spatiu
;       si le stocheaza intr-un vector de octeti.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului de numere in buffer-ul de text.
;       EDI: Pointer la inceputul vectorului de octeti unde se vor salva numerele.
;       ECX: Numarul de elemente de citit (nr_elemente).
;
;   IESIRE (Output):
;       Vectorul de la adresa [EDI] este populat cu numerele convertite.
; =============================================================================
parse_vector_from_buffer:
.loop:
    cmp ecx, 0
    je .end

    ; Convertim un numar din text
    call string_to_integer      ; EAX = numarul convertit, ESI s-a mutat dupa el
    
    ; Stocam numarul in vectorul nostru
    mov [edi], al               ; Presupunem ca numerele incape pe un octet
    
    ; Pregatim pentru urmatoarea iteratie
    inc edi                     ; Mergem la urmatoarea pozitie in vectorul de octeti
    inc esi                     ; Sarim peste spatiu sau newline de dupa numar
    dec ecx
    jmp .loop
.end:
    ret