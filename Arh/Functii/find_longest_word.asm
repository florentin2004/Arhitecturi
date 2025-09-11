; =============================================================================
;   Functia: find_longest_word
; =============================================================================
;   SCOP:
;       Parcurge un sir de caractere terminat prin nul si gaseste primul
;       cuvant de lungime maxima. Cuvintele sunt considerate secvente de
;       caractere delimitate de spatiu (' ').
;
;   INTRARE (Input):
;       ESI: Pointer (adresa) la inceputul sirului de caractere de analizat.
;
;   IESIRE (Output):
;       ECX: Lungimea celui mai lung cuvant gasit.
;       EDX: Pointer (adresa) la primul caracter al celui mai lung cuvant gasit.
;            (pointer direct in sirul original, nu o copie)
;
;   REGISTRE MODIFICATE:
;       EAX, EBX, ECX, EDX, EDI, ESI. Functia foloseste intensiv registrele,
;       deci salvati pe stiva orice valoare importanta inainte de a o apela.
; =============================================================================

find_longest_word:
    ; --- Initializare ---
    xor ebx, ebx            ; EBX va tine max_len, initial 0
    mov edx, esi            ; EDX va tine pointerul la cuvantul maxim

.main_loop:
    ; --- Pas 1: Sarim peste spatiile dintre cuvinte ---
.skip_spaces:
    cmp byte [esi], 0       ; Am ajuns la finalul intregului sir?
    je .end_function        
    cmp byte [esi], ' '
    jne .word_start
    inc esi
    jmp .skip_spaces

.word_start:
    mov edi, esi            ; Am gasit inceputul unui cuvant. Marcam pozitia in EDI.

    ; --- Pas 2: Gasim sfarsitul cuvantului curent ---
.find_end:
    inc esi
    cmp byte [esi], ' '
    je .word_end
    cmp byte [esi], 0
    je .word_end
    jmp .find_end

.word_end:
    ; --- Pas 3: Calculam lungimea cuvantului curent si comparam ---
    mov eax, esi
    sub eax, edi            ; EAX = lungimea cuvantului curent
    
    cmp eax, ebx            ; Comparam lungimea curenta (EAX) cu max_len (EBX)
    jle .main_loop          ; Daca nu e mai mare, reluam bucla de la pozitia curenta a lui ESI

    ; --- Am gasit un nou maxim! Actualizam rezultatele ---
    mov ebx, eax            ; max_len = lungimea curenta
    mov edx, edi            ; max_word_start = pointerul la inceputul cuvantului curent
    
    jmp .main_loop          ; Continuam cautarea

.end_function:
    ; La final, punem rezultatele in registrele de iesire conform conventiei
    mov ecx, ebx            ; ECX = max_len
    ; EDX contine deja pointerul
    ret


;; ------------------------------------------------------------------------
;;  VARIANTA IN CARE FOLOSESTI VARIABILE
;; ------------------------------------------------------------------------
gaseste_cuvant_maxim:
    ; --- Initializare ---
    mov dword [max_len], 0
    mov dword [max_word_start], 0
    mov esi, buffer             ; ESI este pointerul principal de parcurgere

.loop_principala:
    ; --- Pas 1: Sarim peste spatiile initiale (daca exista) ---
.skip_spaces:
    cmp byte [esi], ' '
    jne .inceput_cuvant
    inc esi
    jmp .skip_spaces

.inceput_cuvant:
    cmp byte [esi], 0           ; Daca am ajuns la final, am terminat
    je .end_function
    
    mov edi, esi                ; EDI = pointer la inceputul cuvantului curent

    ; --- Pas 2: Gasim sfarsitul cuvantului curent ---
.find_end_of_word:
    inc esi
    cmp byte [esi], ' '
    je .sfarsit_cuvant
    cmp byte [esi], 0
    je .sfarsit_cuvant
    jmp .find_end_of_word

.sfarsit_cuvant:
    ; --- Pas 3: Calculam lungimea si comparam ---
    mov eax, esi
    sub eax, edi                ; EAX = lungimea cuvantului curent
    
    mov ebx, [max_len]
    cmp eax, ebx
    jle .loop_principala        ; Daca nu e mai mare, continuam cautarea

    ; --- Am gasit un nou maxim! ---
    mov [max_len], eax
    mov [max_word_start], edi
    
    jmp .loop_principala

.end_function:
    ret