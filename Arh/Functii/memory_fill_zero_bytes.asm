; =============================================================================
;   Functia: memory_fill_zero_bytes
; =============================================================================
;   SCOP:
;       Umple o zona de memorie specificata cu octeti de valoare 0.
;       Este utila pentru a initializa/curata buffere sau vectori inainte
;       de a lucra cu ei.
;
;   INTRARE (Input):
;       EDI: Pointer (adresa) la inceputul zonei de memorie care trebuie umpluta.
;       ECX: Lungimea in octeti a zonei de memorie.
;
;   IESIRE (Output):
;       - Zona de memorie specificata este suprascrisa cu octeti de valoare 0.
;       - Functia nu returneaza nicio valoare in registre.
;
;   REGISTRE MODIFICATE:
;       EDI, ECX. Valorile originale ale acestor registre se pierd. Daca aveti
;       nevoie de ele dupa apelul functiei, trebuie sa le salvati pe stiva
;       (ex: push ecx) inainte de a apela functia.
; =============================================================================

memory_fill_zero_bytes:
.loop:
    ; Verificam daca mai avem octeti de scris (daca contorul a ajuns la 0)
    cmp ecx, 0
    je .end                 ; Daca ECX este 0, am terminat, iesim.

    ; Scrie un octet de valoare 0 la adresa curenta indicata de EDI
    mov byte [edi], 0
    
    ; Pregateste pentru urmatoarea iteratie
    inc edi                 ; Muta pointerul la urmatorul octet din memorie
    dec ecx                 ; Decrementeaza contorul
    jmp .loop               ; Repeta procesul

.end:
    ret

; =============================================================================
; SCOP UTILIZARE

SECTION .bss
    buffer_mare resb 256

; ...

_start:
    ; Vrem sa curatam 'buffer_mare' inainte de a citi ceva in el
    mov edi, buffer_mare    ; Incarcam adresa buffer-ului in EDI
    mov ecx, 256            ; Incarcam lungimea (256 octeti) in ECX
    call memory_fill_zero_bytes
    
    ; Acum, cei 256 de octeti de la adresa 'buffer_mare' sunt garantat 0.
    
    ; ... restul programului ...