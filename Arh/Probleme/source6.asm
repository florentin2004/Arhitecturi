SECTION .data
    nume_fisier_in  db 'in6.txt', 0
    nume_fisier_out db 'out6.txt', 0

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
    mov esi, buffer;
    movzx ecx, byte [lungime]
    mov [esi + ecx], byte 0; ii pun terminator de sir
    call get_lungime_maxima
    call integer_to_string_and_write_robust


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

get_lungime_maxima:
    mov esi, buffer;
    xor eax, eax;
    xor edx, edx
.loop_numara:
    cmp dl, al
    jg .modifica_lungime
    movzx ebx, byte [esi]
    inc esi
    cmp ebx, 0
    jz .end_numara
    cmp bl, '1'
    jz .este_1
    xor edx, edx
    jmp .loop_numara
.este_1:
    inc dl
    jmp .loop_numara
.modifica_lungime:
    mov al, dl
    jmp .loop_numara

.end_numara:
    ret;

integer_to_string_and_write_robust:
    mov ebx, 10
    xor ecx, ecx
.r_conversion_loop:
    xor edx, edx
    div ebx
    add edx, '0'
    push edx
    inc ecx
    cmp eax, 0
    jne .r_conversion_loop

.r_write_loop:
    cmp ecx, 0
    je .r_end

    dec ecx
    pop edx
    mov [caracter], dl  ; Folosim buffer-ul intermediar

    pusha                   ; Salvam tot inainte de syscall
    mov eax, 4
    ; Aici primim file descriptor-ul in EBX de la apelant
    mov ebx, [descriptor_out] ; Exemplu de cum ar fi folosit
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa                    ; Restauram tot
    jmp .r_write_loop

.r_end:
    ret


    








