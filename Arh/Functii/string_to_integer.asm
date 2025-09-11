; =============================================================================
;   Functia: string_to_integer (ASCII to Integer / atoi)
; =============================================================================
;   SCOP:
;       Converteste un sir de caractere (cifre) dintr-o locatie de memorie
;       intr-o valoare numerica binara.
;
;   INTRARE (Input):
;       ESI: Un pointer (adresa de memorie) la primul caracter al sirului de cifre.
;
;   IESIRE (Output):
;       EAX: Numarul convertit in format binar (ex: 32767).
;       ESI: Pointerul este mutat la primul caracter de dupa numar (ex: spatiu, newline).
;
;   REGISTRE MODIFICATE:
;       EAX, ECX. Daca e nevoie sa pastrati valorile lor, salvati-le pe stiva
;       inainte de a apela aceasta functie.
; =============================================================================

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


; =============================================================================
;   Functia: string_to_signed_integer
; =============================================================================
;   SCOP:
;       Converteste un sir de caractere (care poate contine '-') intr-un
;       numar intreg cu semn pe 32 de biti.
;
;   INTRARE (Input):
;       ESI: Pointer la inceputul sirului de caractere.
;
;   IESIRE (Output):
;       EAX: Numarul convertit (poate fi negativ).
;       ESI: Pointerul este mutat la primul caracter de dupa numar.
; =============================================================================
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