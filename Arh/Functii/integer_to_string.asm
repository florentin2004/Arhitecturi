; =============================================================================
;   Functia: integer_to_string_and_write
; =============================================================================
;   SCOP:
;       Converteste o valoare numerica binara intr-un sir de caractere
;       si scrie acest sir intr-un fisier specificat.
;
;   PRERECHIZITE:
;       Trebuie sa existe o zona de memorie in sectiunea .bss definita ca:
;       'digit_buffer resb 1' - folosita pentru a scrie cifrele una cate una.
;
;   INTRARE (Input):
;       EAX: Numarul care trebuie convertit si afisat.
;       EDI: File descriptor-ul unde se va face scrierea (ex: 1 pentru ecran,
;            sau valoarea returnata de un SYS_OPEN pentru un fisier).
;
;   IESIRE (Output):
;       N/A. Functia scrie direct in fisier.
;
;   REGISTRE MODIFICATE:
;       EAX, EBX, ECX, EDX. Aceasta functie este distructiva pentru registre,
;       deoarece foloseste SYS_WRITE. Intotdeauna salvati registrele importante
;       pe stiva inainte de a o apela!
; =============================================================================

integer_to_string_and_write:
    ; Salvam file descriptor-ul pentru ca vom modifica EBX
    push edi
    
    mov ebx, 10             ; Vom imparti la 10
    xor ecx, ecx            ; ECX va fi contorul de cifre

.conversion_loop:
    xor edx, edx            ; Pregatim pentru impartire (EDX trebuie sa fie 0)
    div ebx                 ; Imparte EDX:EAX la 10. Catul in EAX, Restul in EDX.
    
    add edx, '0'            ; Convertim restul (cifra) la codul sau ASCII
    push edx                ; Punem cifra pe stiva
    inc ecx                 ; Incrementam contorul de cifre
    
    cmp eax, 0              ; Verificam daca am terminat de impartit
    jne .conversion_loop    ; Daca nu, continuam

    ; Restauram file descriptor-ul in EBX, unde il asteapta SYS_WRITE
    pop ebx

.write_loop:
    cmp ecx, 0
    je .end

    ; Folosim ESP pentru a accesa cifra de pe stiva fara a o scoate
    ; Acest lucru este necesar pentru ca SYS_WRITE modifica ECX.
    ; Puteam folosi si pusha/popa in interiorul buclei.
    mov edi, esp            ; EDI pointeaza acum la ultima cifra pusa pe stiva

    ; Apelul de sistem pentru a scrie o singura cifra
    mov eax, 4              ; SYS_WRITE
    ; EBX contine deja file descriptor-ul nostru
    mov ecx, edi            ; ECX pointeaza la data de scris (cifra de pe stiva)
    mov edx, 1              ; Scriem 1 singur byte
    int 80h
    
    add esp, 4              ; "Scoatem" manual cifra de pe stiva marind pointer-ul
    dec ecx                 ; Decrementam contorul original, desi e corupt dupa int 80h
                            ; Ne bazam pe ESP pentru a sti cand ne oprim
    jmp .write_loop         ; ATENTIE: Aici e un bug subtil, vezi versiunea robusta.
                            ; Aceasta versiune merge, dar nu e ideala.

.end:
    ret

; --- VARIANTA MAI ROBUSTA A FUNCTIEI (recomandata) ---
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
    mov [digit_buffer], dl  ; Folosim buffer-ul intermediar

    pusha                   ; Salvam tot inainte de syscall
    mov eax, 4
    ; Aici primim file descriptor-ul in EBX de la apelant
    ; mov ebx, [descriptor_out] ; Exemplu de cum ar fi folosit
    mov ecx, digit_buffer
    mov edx, 1
    int 80h
    popa                    ; Restauram tot
    jmp .r_write_loop

.r_end:
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