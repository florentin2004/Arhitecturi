SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out5.txt', 0
    spatiu          db ' ', 0
    
SECTION .bss
    buffer          resb 1024
    descriptor_in   resb 4
    descriptor_out  resb 4
    
    vector          resd 100        ; Vector de 100 de DWORD-uri
    nr_elemente     resd 1
    
    caracter        resb 1

SECTION .text
global _start

_start:
    ; --- PASUL 1: Deschide si citeste fisierul ---
    mov eax, 5
    mov ebx, nume_fisier_in
    mov ecx, 0
    int 80h
    mov [descriptor_in], eax

    mov eax, 3
    mov ebx, [descriptor_in]
    mov ecx, buffer
    mov edx, 1024
    int 80h
    mov byte [buffer + eax], 0  ; Adauga terminator nul

    ; --- PASUL 2: Parseaza N si vectorul ---
    call gaseste_newline_in_buffer ; ESI va pointa la newline
    mov byte [esi], 0           ; Inlocuim newline cu nul, separand cele doua siruri
    inc esi                     ; ESI pointeaza acum la inceputul sirului pentru N
    
    call string_to_integer      ; Convertim N la numar. Rezultatul e in EAX.
    mov [nr_elemente], eax
    
    mov esi, buffer             ; Resetam ESI la inceputul buffer-ului (sirul de numere)
    mov edi, vector             ; EDI este destinatia pentru vectorul de numere
    mov ecx, [nr_elemente]      ; ECX este contorul
    call parse_vector_of_dwords
    
    ; --- PASUL 3: Sorteaza vectorul ---
    mov edi, vector
    mov ecx, [nr_elemente]
    call bubble_sort_dwords     ; Sorteaza crescator

    ; --- PASUL 4: Scrie rezultatul in fisier ---
    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax
    
    call afiseaza_ultimele_doua
    
.gata_scrierea:
    ; --- PASUL 5: Inchide fisierele si iesi ---
    mov eax, 6
    mov ebx, [descriptor_in]
    int 80h
    
    mov eax, 6
    mov ebx, [descriptor_out]
    int 80h
    
    mov eax, 1
    xor ebx, ebx
    int 80h


afiseaza_ultimele_doua:
    mov ecx, [nr_elemente]
    cmp ecx, 2
    jl .afiseaza_unul_sau_nimic ; Daca avem mai putin de 2 elemente

    ; --- Gasim max1 si max2 si le SALVAM ---
    mov esi, vector
    
    ; Gasim ultimul element (max1)
    mov edx, ecx                ; edx = N
    dec edx                     ; edx = N-1 (indexul ultimului element)
    mov eax, [esi + edx*4]      ; EAX = max1
    
    push eax                    ; SALVAM max1 pe stiva

.cauta_max2:
    dec edx
    cmp edx, 0
    jl .afiseaza_doar_unul_cu_pop ; Toate elementele sunt la fel
    
    mov ebx, [esi + edx*4]
    cmp eax, ebx
    je .cauta_max2              ; Daca e la fel, cautam mai departe
    
    ; Am gasit max2 in EBX
    push ebx                    ; SALVAM max2 pe stiva
    
    ; --- Acum afisam valorile salvate de pe stiva ---
    ; Stiva arata asa: [max2, max1]
    
    ; Afisam max2
    pop eax                     ; EAX = max2
    call integer_to_string_and_write_robust

    ; Afisam spatiu
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, spatiu
    mov edx, 1
    int 80h
    popa
    
    ; Afisam max1
    pop eax                     ; EAX = max1
    call integer_to_string_and_write_robust
    
    jmp .end_afisare

.afiseaza_unul_sau_nimic:
    cmp ecx, 1
    jne .end_afisare
.afiseaza_doar_unul_cu_pop:
    pop eax                     ; Curatam stiva si luam valoarea
    call integer_to_string_and_write_robust

.end_afisare:
    ret

; =============================================================================
; --- FUNCTII SPECIFICE PROBLEMEI ---
; =============================================================================
gaseste_newline_in_buffer:
    mov esi, buffer
.loop_gnl:
    cmp byte [esi], 0Ah
    je .found_gnl
    inc esi
    jmp .loop_gnl
.found_gnl:
    ret



; =============================================================================
; --- FUNCTII DIN PORTOFOLIU (adaptate/folosite) ---
; =============================================================================
parse_vector_of_dwords:
.loop_parse:
    cmp ecx, 0
    je .end_parse
    cmp byte [esi], 0
    je .end_parse
    cmp byte [esi], ' '
    je .skip_space
    
    push ecx
    push edi
    call string_to_integer
    pop edi
    pop ecx
    
    mov [edi], eax
    add edi, 4
    dec ecx
.skip_space:
    inc esi
    jmp .loop_parse
.end_parse:
    ret

bubble_sort_dwords:
    dec ecx
    jz .end_sort
.loop_exterior_i:
    mov esi, edi
    mov edx, ecx
.loop_interior_j:
    mov eax, [esi]
    mov ebx, [esi + 4]
    cmp eax, ebx
    jle .nu_interschimba
    mov [esi], ebx
    mov [esi + 4], eax
.nu_interschimba:
    add esi, 4
    dec edx
    jnz .loop_interior_j
    dec ecx
    jnz .loop_exterior_i
.end_sort:
    ret

string_to_integer:
    xor eax, eax
.loop_sti:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl .end_sti
    cmp ecx, '9'
    jg .end_sti
    lea eax, [eax*4 + eax]
    shl eax, 1
    sub ecx, '0'
    add eax, ecx
    inc esi
    jmp .loop_sti
.end_sti:
    ret

integer_to_string_and_write_robust:
    mov ebx, 10
    xor ecx, ecx
.r_conversion_loop:
    cmp eax, 0
    je .start_write
    xor edx, edx
    div ebx
    add edx, '0'
    push edx
    inc ecx
    jmp .r_conversion_loop
.start_write:
    cmp ecx, 0
    je .handle_zero
.r_write_loop:
    cmp ecx, 0
    je .r_end
    dec ecx
    pop edx
    mov [caracter], dl
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    jmp .r_write_loop
.handle_zero:
    mov byte [caracter], '0'
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
.r_end:
    ret
