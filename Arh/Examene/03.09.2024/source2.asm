SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out2.txt', 0
    
SECTION .bss
    buffer          resb 1024
    descriptor_in   resb 4
    descriptor_out  resb 4
    caracter        resb 1
    max_len         resd 1
    max_word_start  resd 1

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

    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax

    ; --- PASUL 2: ---
    mov esi, buffer;
    call gaseste_cuvant_maxim
    mov eax, 4
    ; Aici primim file descriptor-ul in EBX de la apelant
    mov ebx, [descriptor_out] ; Exemplu de cum ar fi folosit
    mov ecx, [max_word_start]
    mov edx, [max_len]
    int 80h


    
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


gaseste_cuvant_maxim:
    ; --- Initializare ---
    mov dword [max_len], 0
    mov dword [max_word_start], 0
    mov esi, buffer             ; ESI este pointerul principal de parcurgere

.loop_principala:
    ; --- Pas 1: Sarim peste spatiile initiale (daca exista) ---
.skip_spaces:
    cmp byte [esi], ' '
    jne .inceput_cuvant
    inc esi
    jmp .skip_spaces

.inceput_cuvant:
    cmp byte [esi], 0           ; Daca am ajuns la final, am terminat
    je .end_function
    
    mov edi, esi                ; EDI = pointer la inceputul cuvantului curent

    ; --- Pas 2: Gasim sfarsitul cuvantului curent ---
.find_end_of_word:
    inc esi
    cmp byte [esi], ' '
    je .sfarsit_cuvant
    cmp byte [esi], 0
    je .sfarsit_cuvant
    jmp .find_end_of_word

.sfarsit_cuvant:
    ; --- Pas 3: Calculam lungimea si comparam ---
    mov eax, esi
    sub eax, edi                ; EAX = lungimea cuvantului curent
    
    mov ebx, [max_len]
    cmp eax, ebx
    jle .loop_principala        ; Daca nu e mai mare, continuam cautarea

    ; --- Am gasit un nou maxim! ---
    mov [max_len], eax
    mov [max_word_start], edi
    
    jmp .loop_principala

.end_function:
    ret
