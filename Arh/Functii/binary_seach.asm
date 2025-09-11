; =============================================================================
;   Functia: binary_search
; =============================================================================
;   INTRARE:
;       AL: Elementul cautat
;       [nr_elemente]: Numarul de elemente din vector
;       vector: Adresa vectorului sortat
;
;   IESIRE:
;       EAX: Indexul elementului gasit, sau -1 daca nu a fost gasit.
; =============================================================================
binary_search:
    movzx ebx, byte [nr_elemente]
    cmp ebx, 0
    je .not_found               ; Daca vectorul e gol, nu gasim nimic

    xor eax, eax                ; EAX = stanga (left) = 0
    mov ecx, ebx                ; ECX = dreapta (right)
    dec ecx                     ; dreapta = nr_elemente - 1
    
    movzx edi, byte [element_cautat] ; EDI = elementul pe care il cautam

.loop_search:
    cmp eax, ecx                ; Comparam stanga cu dreapta
    jg .not_found               ; Daca stanga > dreapta, elementul nu exista

    ; Calculam mid = (stanga + dreapta) / 2
    mov edx, eax                ; EDX = stanga
    add edx, ecx                ; EDX = stanga + dreapta
    shr edx, 1                  ; EDX = mid (indexul din mijloc)

    ; Comparam elementul cautat cu vector[mid]
    mov esi, vector
    movzx ebx , byte [esi + edx]  ; BH = valoarea de la vector[mid]
    
    cmp bl, byte [element_cautat]
    je .found
    jg .prea_mare
    jl .prea_mic 

.prea_mare:                     ; vector[mid] > element_cautat
    mov ecx, edx                ; dreapta = mid
    dec ecx                     ; dreapta = mid - 1
    jmp .loop_search            ; Continuam cautarea in jumatatea stanga

.prea_mic:                      ; vector[mid] < element_cautat
    mov eax, edx                ; stanga = mid
    inc eax                     ; stanga = mid + 1
    jmp .loop_search            ; Continuam cautarea in jumatatea dreapta

.found:
    mov eax, edx                ; Am gasit! Returnam indexul (mid)
    ret

.not_found:
    mov eax, -1                 ; Nu am gasit, returnam -1
    ret