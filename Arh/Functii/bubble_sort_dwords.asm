; =============================================================================
;   Functia: bubble_sort_dwords
; =============================================================================
;   SCOP:
;       Sorteaza un vector de numere intregi pe 32 de biti (DWORDs)
;       folosind algoritmul Bubble Sort.
;
;   INTRARE (Input):
;       EDI: Pointer la inceputul vectorului.
;       ECX: Numarul de elemente din vector (N).
;
;   IESIRE (Output):
;       - Vectorul de la adresa [EDI] este sortat in loc.
; =============================================================================
bubble_sort_dwords:
    dec ecx                 ; Vom face N-1 treceri (i de la 0 la N-2)
    jz .end_sort            ; Daca N<=1, e deja sortat

.loop_exterior_i:
    mov esi, edi            ; ESI va fi pointerul pentru bucla interioara (v[j])
    mov edx, ecx            ; EDX va fi contorul pentru bucla interioara

.loop_interior_j:
    ; Comparam v[j] cu v[j+1]
    mov eax, [esi]
    mov ebx, [esi + 4]      ; +4 pentru ca sunt DWORD-uri
    
    cmp eax, ebx
    ; --- AICI E CHEIA PENTRU ORDINE ---
    ; jle -> Jump if Less or Equal -> sorteaza CRESCATOR
    ; jge -> Jump if Greater or Equal -> sorteaza DESCRESCATOR
    jle .nu_interschimba

    ; Interschimbare (swap)
    mov [esi], ebx
    mov [esi + 4], eax

.nu_interschimba:
    add esi, 4              ; Trecem la urmatorul element pentru comparatie
    dec edx
    jnz .loop_interior_j
    
    dec ecx
    jnz .loop_exterior_i

.end_sort:
    ret