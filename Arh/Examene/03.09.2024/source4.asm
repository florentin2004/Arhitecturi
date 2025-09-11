SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out4.txt', 0
    alfabet         db '0123456789ABCDEF'
    
SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    
    numar_de_convertit resd 1
    baza_noua          resd 1
    
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

    ; --- PASUL 2: ---
    mov esi, buffer
    call string_to_integer          ; EAX = numarul
    mov [numar_de_convertit], eax

    call gaseste_newline_in_buffer
    inc esi                         ; Sarim peste newline
    
    call string_to_integer          ; EAX = baza
    mov [baza_noua], eax

    mov eax, [numar_de_convertit]
    mov ebx, [baza_noua]
    call convert_and_write


    
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


gaseste_newline_in_buffer:
    ; ESI este deja setat de la string_to_integer
.loop_gnl:
    cmp byte [esi], 0Ah;   ; ' ' sau orice alt caracter
    je .found_gnl; 
    inc esi; 
    jmp .loop_gnl
.found_gnl:
    ret

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


convert_and_write:
    xor ecx, ecx            ; ECX = contorul de cifre
    ; EAX = numar, EBX = baza
.conversion_loop:
    cmp eax, 0
    je .start_write
    
    xor edx, edx
    div ebx                 ; EAX = cat, EDX = rest
    
    ; EDX contine indexul. Il folosim sa gasim caracterul si punem PE STIVA.
    mov edi, alfabet
    add edi, edx
    movzx edx, byte [edi]
    
    push edx                ; Punem caracterul (ex: 'F') pe stiva.
    inc ecx
    
    jmp .conversion_loop    ; Ne intoarcem cu noul EAX (catul).

.start_write:
    ; La acest punct, stiva contine TOATE caracterele in ordine inversa.
    ; EAX este 0.
    cmp ecx, 0
    je .handle_zero

.write_loop:
    cmp ecx, 0
    je .end_write
    
    dec ecx
    pop edx                 ; Scoatem un CARACTER (ex: 'F') de pe stiva
    mov [caracter], dl
    
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    
    jmp .write_loop

.handle_zero:
    mov byte [caracter], '0'
    pusha; mov eax, 4; mov ebx, [descriptor_out]; mov ecx, caracter; mov edx, 1; int 80h; popa

.end_write:
    ret
