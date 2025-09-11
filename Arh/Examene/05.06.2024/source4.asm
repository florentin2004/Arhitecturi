SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out4.txt', 0
    spatiu          db ' ', 0
    
SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    ; Vectorul unde vom stoca [zile, ore, minute, secunde]
    timp            resd 4
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
    call string_to_integer
    call converteste_secunde
    call afiseaza_timp
    

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


; INTRARE: EAX = numarul total de secunde
; IESIRE: vectorul 'timp' este populat
converteste_secunde:
    ; --- Calculeaza SECUNDELE si totalul de MINUTE ---
    mov ebx, 60
    xor edx, edx
    div ebx
    ; EDX = rest (secundele finale), EAX = cat (totalul de minute)
    mov [timp + 12], edx        ; Stocam secundele la timp[3] (index 3 * 4 bytes)
    
    ; --- Calculeaza MINUTELE si totalul de ORE ---
    ; EAX contine deja totalul de minute
    mov ebx, 60
    xor edx, edx
    div ebx
    ; EDX = rest (minutele finale), EAX = cat (totalul de ore)
    mov [timp + 8], edx         ; Stocam minutele la timp[2]
    
    ; --- Calculeaza ORELE si totalul de ZILE ---
    ; EAX contine deja totalul de ore
    mov ebx, 24
    xor edx, edx
    div ebx
    ; EDX = rest (orele finale), EAX = cat (zilele)
    mov [timp + 4], edx         ; Stocam orele la timp[1]
    mov [timp], eax             ; Stocam zilele la timp[0]
    
    ret

; Afiseaza cele 4 componente ale vectorului 'timp'
afiseaza_timp:
    ; Afiseaza zilele
    mov eax, [timp]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza orele
    mov eax, [timp + 4]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza minutele
    mov eax, [timp + 8]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza secundele
    mov eax, [timp + 12]
    call integer_to_string_and_write_robust
    ret

scrie_spatiu:
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, spatiu
    mov edx, 1
    int 80h
    popa
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
