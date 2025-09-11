SECTION .data
    nume_fisier_in  db 'in4.txt', 0
    nume_fisier_out db 'out4.txt', 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resb 1
    caracter        resb 1

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

    ; --- PASUL 2: ---
    call scriere_in_fisier

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

scriere_in_fisier:
    mov eax, buffer
    movzx ecx, byte [lungime]
.loop_scriere:
    cmp ecx, 0
    jz .end_scriere
    movzx ebx, byte [eax]
    cmp ebx, 'A'
    jl .scriere_caracter

.scriere_doua_cifre:
    mov [caracter], byte 31h
    pusha
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, caracter    ; ECX = adresa datelor de scris
    mov edx, 1          ; EDX = lungimea datelor de scris
    int 80h
    popa
    sub bl, 'A'
    add bl, 30h

.scriere_caracter:
    mov [caracter], bl
    pusha
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, caracter    ; ECX = adresa datelor de scris
    mov edx, 1          ; EDX = lungimea datelor de scris
    int 80h
    popa
    inc eax;
    dec ecx;
    jmp .loop_scriere

.end_scriere:
    ret;
    








