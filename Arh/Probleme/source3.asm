SECTION .data
    nume_fisier_in  db 'in3.txt', 0
    nume_fisier_out db 'out3.txt', 0
    dictionar db 'abcdefghijklmnopqrstuvwxyz', 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resb 1
    text            resb 98
    cheie           resb 1
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

    ; --- PASUL 2: ---
    call salvare_text
    push esi
    call lungime_dictionar;
    mov [lungime], al
    pop esi

    mov ebx, eax
    movzx eax, byte [esi]
    movzx ecx, byte [esi +1]
    add eax, ecx;
    xor edx, edx
    div ebx
    mov [cheie], dl
    ; aici s-a salvat cheia
    call scriere_rezultat
    

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


salvare_text:
    mov esi, buffer;
    mov edi, text;
    movzx ecx, byte [lungime]
    sub ecx, 2
.loop_salvare:
    cmp ecx, 0
    jz .end_salvare
    movzx ebx, byte [esi]
    mov [edi], ebx
    inc esi;
    inc edi;
    dec ecx
    jmp .loop_salvare
.end_salvare:
    mov [edi], byte 0h
    ; sa aiba terminator de sir pentru afisare
    ret

lungime_dictionar:
    xor eax, eax
    mov esi, dictionar
.loop_dictionar:
    cmp byte [esi], 0
    jz .end_dictionar
    inc esi;
    inc eax;
    jmp .loop_dictionar
.end_dictionar:
    ret


;; ______________________________
;; MAI TREBUIE DOAR SCRIEREA
;; pe scurt cauti in esi si cand gasesti aduni sau scazi cheia si dupa salvezi caracterul si afisezi
;;-------------------------------
scriere_rezultat:
    mov edi, text;
    mov esi, dictionar;
loop_scriere:
    xor ecx, ecx
loop_cauta_caracter:
    movzx ebx, byte [edi]
    cmp ebx, 0
    jz .end_scriere
    movzx eax, byte [esi + ecx]
    cmp eax, ebx
    jz .scriere_caracter
    inc ecx;
    jmp loop_cauta_caracter

.scriere_caracter:

    movzx eax, byte [cheie]
    add eax, ecx
    movzx ebx, byte [lungime]
    xor edx, edx
    div ebx
    movzx eax, byte [esi +edx] 
    mov [caracter], al
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, caracter    ; ECX = adresa datelor de scris
    mov edx, 1          ; EDX = lungimea datelor de scris
    int 80h

    inc edi
    jmp loop_scriere

.end_scriere:
    ret




