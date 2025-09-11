SECTION .data
    nume_fisier_in  db 'in8.txt', 0
    nume_fisier_out db 'out8.txt', 0
    esec            db 'EROARE',0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resb 1
    dictionar       resb 50
    cuvant          resb 50
    lungime_dic     resb 1
    rezultat        resb 50
    lungime_rez     resb 1

SECTION .text
global _start

_start:
    ; --- PASUL 1: Deschide si citeste fisierul de intrare ---
    mov eax, 5
    mov ebx, nume_fisier_in
    mov ecx, 0
    int 80h
    mov [descriptor_in], eax

    mov eax, 3
    mov ebx, [descriptor_in]
    mov ecx, buffer
    mov edx, 100
    int 80h
    ; salvez lungimea
    mov [lungime], al

    mov eax, 5                  ; Apel de sistem SYS_OPEN
    mov ebx, nume_fisier_out        ; EBX = adresa numelui de fisier
    mov ecx, 65                 ; ECX = flag-uri. 65 = O_WRONLY (1) | O_CREAT (64)
    mov edx, 0644o              ; EDX = permisiunile fisierului (mod octal)
                                ; 0644o = proprietarul poate citi/scrie, restul doar citi
    int 80h
        
    mov [descriptor_out], eax

    ; --- PASUL 2: Parseaza datele din buffer ---
    movzx ecx, byte [lungime]
    mov [buffer + ecx], byte 0;
    mov esi, buffer
    mov edi , dictionar
    call read_line_from_buffer
    mov edi ,cuvant
    call read_line_from_buffer
    mov esi, dictionar
    call string_length
    mov [lungime_dic], cl
    call make_rezultat
    mov esi, rezultat;
    call string_length
    mov [lungime_rez], cl

    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, rezultat     ; ECX = adresa datelor de scris
    movzx edx, byte [lungime_rez]          ; EDX = lungimea datelor de scris
    int 80h
    jmp .gata_scrierea

.este_esec:
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, esec     ; ECX = adresa datelor de scris
    mov edx, 6          ; EDX = lungimea datelor de scris
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

read_line_from_buffer:
.loop:
    mov al, [esi]
    cmp al, 0Ah             ; Compara cu newline
    je .end
    cmp al, 0
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


make_rezultat:
    mov esi, dictionar
    mov edi, cuvant
    mov eax, rezultat       ; EAX = pointer la buffer-ul de iesire

.loop_make:
    movzx ebx, byte [edi]
    cmp ebx, 0
    jz .end_make
    
    ; Calculeaza indexul caracterului ('a'->0, 'b'->1 etc.)
    sub ebx, 'a'
    
    ; Verifica daca indexul este valid in dictionarul dat
    cmp bl, byte [lungime_dic]
    jge _start.este_esec        ; FIX #1: Folosim JGE in loc de JZ
    
    ; Gaseste caracterul de substitutie
    movzx ecx, byte [esi + ebx]
    
    ; Scrie caracterul in buffer-ul de rezultat
    mov [eax], cl
    
    inc edi                 ; Avansam pointerul sursa
    inc eax                 ; Avansam pointerul destinatie (FIX #2)
    jmp .loop_make

.end_make:
    mov byte [eax], 0       ; Adaugam terminatorul nul la finalul rezultatului
    ret



