SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out4.txt', 0
    tabel_dispersie db 0,0,0,0,0
    newline         db 0Ah, 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resd 1
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
    mov [lungime], eax

    mov eax, 5                  ; Apel de sistem SYS_OPEN
    mov ebx, nume_fisier_out        ; EBX = adresa numelui de fisier
    mov ecx, 65                 ; ECX = flag-uri. 65 = O_WRONLY (1) | O_CREAT (64)
    mov edx, 0644o              ; EDX = permisiunile fisierului (mod octal)
                                ; 0644o = proprietarul poate citi/scrie, restul doar citi
    int 80h
        
    mov [descriptor_out], eax

    ; --- PASUL 2: Parseaza datele din buffer ---
    movzx ecx, byte [lungime] 
    mov esi, buffer
    mov [esi + ecx], byte 0;
    ; am pus 0 la sfarsit sa stiu ca am terminat
    call calculeaza_dispersie
    pusha
    call afisare_tabel_dispersie
    movzx eax, byte [newline]
    mov [caracter], al
    call scriere_caracter
    popa
    mov eax, ecx;
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

calculeaza_dispersie:
    xor ecx, ecx ; contorul pentru coliziuni
    mov ebx, 5
.loop:
    movzx eax, byte [esi]
    cmp eax, 0
    jz .end;
    inc esi;
    xor edx, edx
    div ebx
    cmp byte[tabel_dispersie+edx], 2
    jge .aduna
    inc byte [tabel_dispersie+edx]
    jmp .loop

.aduna:
    inc ecx;
    jmp .loop

.end:
    ret

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

scriere_caracter:
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, caracter     ; ECX = adresa datelor de scris
    mov edx, 1          ; EDX = lungimea datelor de scris
    int 80h
.end:
    ret

afisare_tabel_dispersie:
    xor ecx, ecx
.loop:
    movzx eax, byte [tabel_dispersie + ecx]
    add al, '0'
    mov [caracter], al;
    pusha
    call scriere_caracter
    mov [caracter], byte ' '
    call scriere_caracter
    popa
    inc ecx;
    cmp ecx, 5
    jz .end;
    jmp .loop
.end:
    ret

