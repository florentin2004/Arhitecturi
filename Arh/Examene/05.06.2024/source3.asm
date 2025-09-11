SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out3.txt', 0
    
SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    vector          resd 100
    caracter        resb 1
    lungime_vector  resb 1
    k               resb 1

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
    mov edi, vector;
    call parse_and_count_vector_dwords
    mov [lungime_vector], cl;
    inc esi;
    call string_to_integer
    mov [k], al;
    mov edi, vector;
    movzx ecx, byte [lungime_vector] 
    call bubble_sort_dwords
    movzx eax, byte [k];
    movzx ebx, byte [lungime_vector]
    xor edx, edx;
    div ebx;
    mov esi, vector
    call find_k_element;
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


bubble_sort_dwords:
    dec ecx                 ; Vom face N-1 treceri (i de la 0 la N-2)
    jz .end_sort            ; Daca N<=1, e deja sortat

.loop_exterior_i:
    mov esi, edi            ; ESI va fi pointerul pentru bucla interioara (v[j])
    mov edx, ecx            ; EDX va fi contorul pentru bucla interioara

.loop_interior_j:
    ; Comparam v[j] cu v[j+1]
    mov eax, [esi]
    mov ebx, [esi + 4]      ; +4 pentru ca sunt DWORD-uri
    
    cmp eax, ebx
    ; --- AICI E CHEIA PENTRU ORDINE ---
    ; jle -> Jump if Less or Equal -> sorteaza CRESCATOR
    ; jge -> Jump if Greater or Equal -> sorteaza DESCRESCATOR
    jle .nu_interschimba

    ; Interschimbare (swap)
    mov [esi], ebx
    mov [esi + 4], eax

.nu_interschimba:
    add esi, 4              ; Trecem la urmatorul element pentru comparatie
    dec edx
    jnz .loop_interior_j
    
    dec ecx
    jnz .loop_exterior_i

.end_sort:
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

find_k_element:
    ; in edx ai k
.loop:
    mov eax, [esi];
    cmp edx, 0
    jz .end;
    dec edx;
    add esi, 4;
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
