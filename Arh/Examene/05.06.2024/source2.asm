SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out2.txt', 0
    
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
    call string_to_signed_integer          ; EAX = numarul1
    mov [numar1], eax
    inc esi; trecem peste spatiu
    call string_to_signed_integer          ; EAX = numarul2
    mov [numar2], eax
    mov ebx, [numar1];
    inc esi;
    movzx ecx, byte [esi];
    cmp ecx, '+'
    jz .este_adunare
    cmp ecx, '-'
    jz .este_scadere
    cmp ecx, '*'
    jz .este_inmultire
    cmp ecx, '/'
    jz .este_impartire

.este_adunare:
    add ebx, eax;
    mov [numar_rez], ebx;
    jmp .scriere

.este_scadere:
    sub ebx, eax;
    mov [numar_rez],ebx
    jmp .scriere

.este_inmultire:
    imul ebx, eax;
    mov [numar_rez], ebx;
    jmp .scriere

.este_impartire:
    ; Vrem sa facem EBX / EAX
    xchg eax, ebx   ; Acum EAX = numar1, EBX = numar2
    xor edx, edx
    div ebx         ; Imparte EAX la EBX. Rezultatul (catul) este in EAX.
    mov [numar_rez], eax

.scriere:
    mov eax, [numar_rez]
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


    

string_to_signed_integer:
    ; --- Pas 1: Verificam semnul ---
    xor ebx, ebx            ; EBX va fi flag-ul nostru de semn. 0 = pozitiv, 1 = negativ.
    
    mov al, [esi]
    cmp al, '-'
    jne .incepe_conversia   ; Daca nu e '-', sari direct la conversie

    ; Daca am ajuns aici, numarul este negativ
    mov ebx, 1              ; Setam flag-ul de negativ
    inc esi                 ; Avansam pointerul pentru a sari peste '-'

.incepe_conversia:
    ; --- Pas 2: Convertim partea numerica (logica ta veche) ---
    xor eax, eax
.loop:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl .end
    cmp ecx, '9'
    jg .end
    lea eax, [eax*4 + eax]
    shl eax, 1
    sub ecx, '0'
    add eax, ecx
    inc esi
    jmp .loop

.end:
    ; --- Pas 3: Aplicam semnul ---
    cmp ebx, 1
    jne .gata               ; Daca flag-ul nu e 1 (nu e negativ), am terminat
    
    neg eax                 ; Daca a fost negativ, aplicam negarea
    
.gata:
    ret



; --- VARIANTA CEA MAI ROBUSTA A FUNCTIEI (PERFECTA) ---
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
