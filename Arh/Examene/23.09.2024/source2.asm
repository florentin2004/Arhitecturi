SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out2.txt', 0

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
    mov [buffer + ecx], byte 0;
    mov esi, buffer

    call string_to_integer

    call suma_cifrelor
    add eax, '0'
    mov [caracter], al
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, caracter     ; ECX = adresa datelor de scris
    mov edx, 1          ; EDX = lungimea datelor de scris
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


suma_cifrelor:
    ; in eax este numarul
    xor ecx, ecx; ;aici o sa fie suma cifrelor
    mov ebx, 10;
.loop:
    xor edx, edx
    div ebx
    add ecx, edx;
    cmp eax, 0
    jz .end
    jmp .loop

.end:
    mov eax, ecx;
    cmp eax, 9
    jg suma_cifrelor
    ret




