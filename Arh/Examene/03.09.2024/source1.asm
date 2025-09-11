SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out1.txt', 0
    ALFABET         db 'ud0Eeq34sWYA67cJoylv8259Gx', 0
    
SECTION .bss
    buffer          resb 1024
    descriptor_in   resb 4
    descriptor_out  resb 4
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

    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax

    ; --- PASUL 2: Parseaza N si vectorul ---
    mov esi, buffer;
    call afiseaza_rezultat

    
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


afiseaza_rezultat:
.loop:
    movzx eax, byte [esi];
    cmp eax, 0;
    jz .end;
    sub eax, 'a';
    movzx ebx, byte [ALFABET+eax];
    mov [caracter], bl;

    mov eax, 4
    ; Aici primim file descriptor-ul in EBX de la apelant
    mov ebx, [descriptor_out] ; Exemplu de cum ar fi folosit
    mov ecx, caracter
    mov edx, 1
    int 80h

    inc esi;
    jmp .loop 
.end:
    ret
