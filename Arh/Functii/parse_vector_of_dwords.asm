; =============================================================================
;   Functia: parse_vector_of_dwords
; =============================================================================
;   SCOP:
;       Parcurge un buffer de text (presupunand ca este terminat prin nul),
;       converteste fiecare numar separat prin spatiu intr-un DWORD (4 octeti)
;       si stocheaza aceste numere intr-un vector destinatie.
;
;   PRERECHIZITE:
;       - Functia 'string_to_integer' trebuie sa fie disponibila.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului de numere in buffer-ul de text.
;       EDI: Pointer la inceputul vectorului de DWORD-uri unde se vor salva numerele.
;
;   IESIRE (Output):
;       - Vectorul de la adresa [EDI] este populat cu numerele convertite.
;       - Functia adauga un terminator de 4 octeti de 0 la finalul vectorului.
;
;   REGISTRE MODIFICATE:
;       EAX, EBX, ECX, EDX (prin apelul la string_to_integer).
; =============================================================================

parse_vector_of_dwords:
.loop:
    ; Verificam daca am ajuns la finalul buffer-ului de text
    cmp byte [esi], 0
    je .end_parsing

    ; Daca ESI pointeaza la un spatiu, il sarim
    cmp byte [esi], ' '
    je .skip_space

    ; Convertim un numar din text incepand de la pozitia curenta a lui ESI
    call string_to_integer      ; EAX = numarul convertit, ESI s-a mutat dupa el
    
    ; Stocam numarul (DWORD) in vectorul nostru
    mov [edi], eax
    
    ; Pregatim pentru urmatoarea iteratie
    add edi, 4                  ; Mergem la urmatoarea pozitie in vectorul de DWORD-uri
    jmp .loop

.skip_space:
    inc esi
    jmp .loop

.end_parsing:
    ; Adaugam un terminator de 4 octeti de 0 la finalul vectorului
    mov dword [edi], 0
    ret




; =============================================================================
;   Functia: parse_and_count_vector_dwords
; =============================================================================
;   SCOP:
;       Parcurge un buffer de text pana la newline, converteste fiecare numar
;       si il stocheaza intr-un vector de DWORD-uri. De asemenea, numara
;       elementele parsate.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului de numere.
;       EDI: Pointer la inceputul vectorului unde se vor salva numerele.
;
;   IESIRE (Output):
;       ECX: Numarul de elemente care au fost parsate si adaugate in vector.
;       ESI: Pointerul este mutat la newline.
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