SECTION .data
    nume_fisier_in  db 'in9.txt', 0
    nume_fisier_out db 'out9.txt', 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resb 1
    vector          resd 100
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

    ; --- PASUL 2: Parseaza datele din buffer ---
    movzx ecx, byte [lungime] 
    mov esi, buffer
    mov [esi + ecx], byte 0;
    mov edi, vector;
    call parse_vector_from_buffer
    mov esi, vector;
    call afisare_rezultat


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


parse_vector_from_buffer:
.loop:
    ; Convertim un numar din text
    call string_to_integer      ; EAX = numarul convertit, ESI s-a mutat dupa el
    
    ; Stocam numarul in vectorul nostru
    mov [edi], eax               ; numerele sunt double word deci 4 octeti
    
    cmp [esi], byte 0;
    jz .end

    ; Pregatim pentru urmatoarea iteratie
    add edi,4                     ; Mergem la urmatoarea pozitie in vectorul de octeti
    inc esi                     ; Sarim peste spatiu sau newline de dupa numar
    jmp .loop
.end:
    add edi, 4;
    mov [edi], dword 0
    ; i-am adaugat terminator de sir
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


afisare_rezultat:
    ; ESI pointeaza la inceputul vectorului de DWORD-uri
.loop:
    mov eax, [esi]          ; Luam numarul curent in EAX
    cmp eax, 0
    je .end                 ; Daca e 0, am ajuns la terminator, gata.

    ; --- Algoritmul: (EAX / 100) % 10 ---
    
    ; Pas 1: Impartim la 100
    mov ebx, 100
    xor edx, edx
    div ebx                 ; Acum in EAX avem N / 100 (ex: 5892 -> 58)
    
    ; Pas 2: Impartim rezultatul la 10 pentru a obtine restul
    mov ebx, 10
    xor edx, edx
    div ebx                 ; Acum in EDX avem cifra sutelor (ex: 58 -> rest 8)

    ; --- Afisarea cifrei ---
    add edx, '0'            ; Convertim cifra la caracter ASCII
    mov [caracter], dl

    ; Scrie cifra in fisier
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    
    ; --- Pregatire pentru urmatoarea iteratie ---
    add esi, 4              ; Trecem la urmatorul numar din vector
    
    ; Verificam daca mai avem numere de procesat inainte de a scrie spatiul
    mov eax, [esi]
    cmp eax, 0
    je .end                 ; Daca urmatorul e terminatorul, nu mai scriem spatiu

    ; Scrie un spatiu
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov dword [caracter], ' '  ; O modalitate de a pune ' ' in memorie
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa

    jmp .loop

.end:
    ret
