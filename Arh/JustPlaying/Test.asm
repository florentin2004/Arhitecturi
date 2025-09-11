; =============================================================================
;   Problema: Produsul numerelor pare, rezultat pe 16 biti in hexa
; =============================================================================
SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out.txt', 0
    hex_chars       db '0123456789ABCDEF'

SECTION .bss
    buffer          resb 1024
    descriptor_in   resb 4
    descriptor_out  resb 4
    vector          resd 100
    caracter        resb 1

SECTION .text
global _start

_start:
    ; --- PASUL 1: Citire & Creare fisiere ---
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
    mov byte [buffer + eax], 0

    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax

    ; --- PASUL 2: Parseaza vectorul ---
    mov esi, buffer
    mov edi, vector
    call parse_and_count_vector_dwords
    ; ECX contine acum numarul de elemente

    ; --- PASUL 3: Calculeaza produsul ---
    mov edi, vector
    call calculeaza_produs_pare
    ; Rezultatul este in AX

    ; --- PASUL 4: Afiseaza rezultatul in hexa ---
    call write_hex_word

.gata_scrierea:
    ; --- PASUL 5: Inchidere si iesire ---
    mov eax, 6
    mov ebx, [descriptor_in]
    int 80h
    
    mov eax, 6
    mov ebx, [descriptor_out]
    int 80h
    
    mov eax, 1
    xor ebx, ebx
    int 80h

; =============================================================================
; --- FUNCTII SPECIFICE PROBLEMEI ---
; =============================================================================
calculeaza_produs_pare:
    ; INTRARE: EDI = pointer la vector, ECX = numarul de elemente
    ; IESIRE: EAX = produsul (doar 16 biti sunt relevanti)
    mov eax, 1                  ; EAX tine produsul, initial 1
.loop_produs:
    cmp ecx, 0
    je .end_produs
    
    mov ebx, [edi]              ; Luam un numar din vector in EBX
    
    test ebx, 1                 ; Testam daca e par (ultimul bit e 0?)
    jnz .nu_e_par               ; Daca nu e zero (impar), sarim peste inmultire
    
    imul eax, ebx               ; Inmultim produsul curent cu numarul par
                                ; imul cu 2 operanzi trunchiaza automat rezultatul
.nu_e_par:
    add edi, 4
    dec ecx
    jmp .loop_produs
.end_produs:
    ret

write_hex_word:
    ; INTRARE: EAX = numarul de afisat (ne uitam la AX)
    
    mov edi, 16             ; EDI va fi contorul de biti, incepem de sus (16 biti)

.loop_hex:
    sub edi, 4              ; Trecem la urmatoarea cifra (incepem cu 12, apoi 8, 4, 0)
    
    mov ecx, edi            ; Punem numarul de biti de shiftat in ECX
    
    mov edx, eax            ; Copiem numarul
    shr edx, cl             ; SHIFT cu CL. Aceasta este instructiunea valida!
    
    and edx, 0x0F           ; Pastram doar cei 4 biti (cifra noastra)
    
    ; Afisam cifra din EDX
    pusha
    mov eax, edx
    mov edi, hex_chars
    add edi, eax
    mov al, [edi]
    mov [caracter], al
    
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    
    cmp edi, 0              ; Am terminat toti cei 16 biti?
    jne .loop_hex

.end_hex:
    ret

; =============================================================================
; --- FUNCTII DIN PORTOFOLIU ---
; =============================================================================
parse_and_count_vector_dwords:
    xor ecx, ecx            ; ECX este contorul nostru, il pornim de la 0

.loop_parse:
    ; Sarim peste spatiile de la inceput
.skip_space:
    cmp byte [esi], ' '
    jne .not_space
    inc esi
    jmp .skip_space

.not_space:
    ; Verificam daca am ajuns la finalul liniei
    cmp byte [esi], 0Ah
    je .end_parse
    cmp byte [esi], 0
    je .end_parse

    ; Convertim un numar
    push ecx                ; Salvam contorul
    push edi                ; Salvam pointerul la vector
    call string_to_integer  ; EAX = numarul, ESI s-a mutat dupa el
    pop edi
    pop ecx
    
    ; Stocam numarul in vector si incrementam contoarele/pointerii
    mov [edi], eax
    add edi, 4
    inc ecx
    
    jmp .loop_parse

.end_parse:
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