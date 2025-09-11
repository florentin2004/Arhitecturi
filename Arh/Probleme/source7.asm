SECTION .data
    nume_fisier_in  db 'in7.txt', 0
    nume_fisier_out db 'out7.txt', 0
    esec            db '-1', 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resb 1
    caracter        resb 1
    element_cautat  resb 1
    nr_elemente     resb 1
    vector          resb 100

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

    ; --- PASUL 2: Parseaza datele din buffer ---
    mov esi, buffer
    
    ; Citeste elementul cautat
    call string_to_integer
    mov [element_cautat], al
    inc esi ; Sare peste newline
    
    ; Citeste numarul de elemente
    call string_to_integer
    mov [nr_elemente], al
    inc esi ; Sare peste newline
    
    ; Parseaza vectorul de numere
    movzx ecx, byte [nr_elemente]
    mov edi, vector
    call parse_vector_from_buffer

    ; --- PASUL 3: Cauta elementul ---
    call binary_search
    ; Rezultatul (indexul sau -1) se afla acum in EAX

    cmp eax, -1
    je .scrie_esec

    inc eax

.scrie_succes:
    call integer_to_string_and_write_robust
    jmp .gata_scrierea
    
.scrie_esec:
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, esec
    mov edx, 2
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


binary_search:
    movzx ebx, byte [nr_elemente]
    cmp ebx, 0
    je .not_found               ; Daca vectorul e gol, nu gasim nimic

    xor eax, eax                ; EAX = stanga (left) = 0
    mov ecx, ebx                ; ECX = dreapta (right)
    dec ecx                     ; dreapta = nr_elemente - 1
    
    movzx edi, byte [element_cautat] ; EDI = elementul pe care il cautam

.loop_search:
    cmp eax, ecx                ; Comparam stanga cu dreapta
    jg .not_found               ; Daca stanga > dreapta, elementul nu exista

    ; Calculam mid = (stanga + dreapta) / 2
    mov edx, eax                ; EDX = stanga
    add edx, ecx                ; EDX = stanga + dreapta
    shr edx, 1                  ; EDX = mid (indexul din mijloc)

    ; Comparam elementul cautat cu vector[mid]
    mov esi, vector
    movzx ebx , byte [esi + edx]  ; BH = valoarea de la vector[mid]
    
    cmp bl, byte [element_cautat]
    je .found
    jg .prea_mare
    jl .prea_mic 

.prea_mare:                     ; vector[mid] > element_cautat
    mov ecx, edx                ; dreapta = mid
    dec ecx                     ; dreapta = mid - 1
    jmp .loop_search            ; Continuam cautarea in jumatatea stanga

.prea_mic:                      ; vector[mid] < element_cautat
    mov eax, edx                ; stanga = mid
    inc eax                     ; stanga = mid + 1
    jmp .loop_search            ; Continuam cautarea in jumatatea dreapta

.found:
    mov eax, edx                ; Am gasit! Returnam indexul (mid)
    ret

.not_found:
    mov eax, -1                 ; Nu am gasit, returnam -1
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



parse_vector_from_buffer:
.loop:
    cmp ecx, 0
    je .end

    ; Convertim un numar din text
    call string_to_integer      ; EAX = numarul convertit, ESI s-a mutat dupa el
    
    ; Stocam numarul in vectorul nostru
    mov [edi], al               ; Presupunem ca numerele incape pe un octet
    
    ; Pregatim pentru urmatoarea iteratie
    inc edi                     ; Mergem la urmatoarea pozitie in vectorul de octeti
    inc esi                     ; Sarim peste spatiu sau newline de dupa numar
    dec ecx
    jmp .loop
.end:
    ret

