SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out5.txt', 0
    alfabet         db '0123456789ABCDEF'
    
SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    
    numar1          resd 1
    numar2          resd 1
    
    caracter        resb 1
    numar_rez       resd 1

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
    mov esi, buffer
    call string_to_integer          ; EAX = numarul1
    mov [numar1], eax
    inc esi; trecem peste spatiu
    call string_to_integer          ; EAX = numarul2
    mov [numar2], eax

    call numar_de_biti_1
    mov edx, ecx;
    mov eax, [numar1]
    call numar_de_biti_1
    mov ebx, ecx;
    cmp edx, ebx
    jge .al_doilea_nr
    mov ebx, [numar1]
    mov [numar_rez], ebx
    jmp .scriere

.al_doilea_nr:
    mov edx, [numar2]
    mov [numar_rez], edx;

.scriere:
    mov eax, [numar_rez];
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


    

string_to_integer:
    xor eax, eax            ; Initializam rezultatul (EAX) cu 0

.loop:
    movzx ecx, byte [esi]   ; Luam un caracter din buffer, extins la 32 biti cu zero
    
    ; Verificam daca e cifra ('0'...'9')
    cmp ecx, '0'
    jl .end                 ; Daca e mai mic, nu e cifra (ex: newline), am terminat
    cmp ecx, '9'
    jg .end                 ; Daca e mai mare, nu e cifra, am terminat

    ; Algoritmul de conversie: rezultat = (rezultat * 10) + cifra_noua
    ; 1. Inmulteste EAX (rezultatul curent) cu 10
    ;    (folosim 'lea' ca o optimizare, dar 'imul eax, 10' e la fel de bun)
    lea eax, [eax*4 + eax]  ; EAX = EAX * 5
    shl eax, 1              ; EAX = EAX * 2  (Total: EAX * 10)
    
    ; 2. Converteste caracterul din ECX in valoarea sa numerica
    sub ecx, '0'            ; '5' (cod 53) - '0' (cod 48) = 5
    
    ; 3. Aduna cifra noua la rezultat
    add eax, ecx
    
    inc esi                 ; Treci la urmatorul caracter
    jmp .loop

.end:
    ret

numar_de_biti_1:
    xor ecx, ecx
.loop:
    cmp eax, 0
    je .end
    
    shr eax, 1      ; Deplaseaza bitii. Ultimul bit ajunge in CF.
    jnc .loop       ; Jump if Not Carry. Daca CF=0 (bitul era 0), sari direct la urmatoarea iteratie.
    
    ; Daca am ajuns aici, inseamna ca CF=1 (bitul era 1)
    inc ecx
    
    jmp .loop
.end:
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

