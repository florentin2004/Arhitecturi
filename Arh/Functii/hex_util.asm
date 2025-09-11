; =============================================================================
;   Functia: write_byte_as_hex
; =============================================================================
;   SCOP:
;       Converteste un octet intr-o reprezentare de 2 caractere hexazecimale
;       si le scrie intr-un fisier dat.
;
;   PRERECHIZITE (trebuie definite in programul principal):
;       SECTION .data
;           hex_chars db '0123456789ABCDEF'
;       SECTION .bss
;           hex_char_buffer resb 1
;           descriptor_out  resb 4      ; (trebuie sa contina un file descriptor valid)
;
;   INTRARE (Input):
;       AL: Octetul care trebuie convertit si scris (ex: 0x5A).
;
;   IESIRE (Output):
;       N/A. Functia scrie direct in fisierul specificat de 'descriptor_out'.
;
;   REGISTRE MODIFICATE:
;       EAX, EBX, ECX, EDX. Functia este distructiva pentru registre.
; =============================================================================
write_byte_as_hex:
    ; Salvam o copie a octetului in registrul AH, care nu este afectat de operatii pe AL
    mov ah, al

    ; --- Proceseaza prima jumatate (high nibble) ---
    shr al, 4                   ; Deplaseaza 4 biti la dreapta (ex: 0x5A -> 0x05)
    
    ; Gaseste si scrie caracterul corespunzator
    call write_nibble_to_file

    ; --- Proceseaza a doua jumatate (low nibble) ---
    mov al, ah                  ; Restaureaza octetul original din AH
    and al, 0x0F                ; Mascheaza bitii de sus (ex: 0x5A -> 0x0A)
    
    ; Gaseste si scrie caracterul corespunzator
    call write_nibble_to_file
    
    ret

; --- Functie ajutatoare, nu se apeleaza direct ---
; INTRARE: AL = valoare de 4 biti (0-15)
write_nibble_to_file:
    pusha                       ; Salvam toate registrele pentru a fi siguri
    
    ; Gaseste caracterul in tabela de conversie
    mov ebx, hex_chars
    add ebx, eax                ; EBX pointeaza acum la caracterul HEX corect
    mov al, [ebx]               ; AL contine acum caracterul de afisat (ex: '5' sau 'A')
    mov [hex_char_buffer], al   ; Il punem intr-un buffer de memorie sigur
    
    ; Apel de sistem pentru a scrie 1 caracter in fisier
    mov eax, 4                  ; SYS_WRITE
    mov ebx, [descriptor_out]
    mov ecx, hex_char_buffer    ; ADRESA buffer-ului nostru
    mov edx, 1                  ; Lungimea: 1 octet
    int 80h
    
    popa                        ; Restauram toate registrele
    ret


   hex_chars       db '0123456789ABCDEF'


; =============================================================================
; --- NOUA FUNCTIE DE AFISARE PE 16 BITI ---
; --- Aceasta inlocuieste complet 'write_hex_word_corect' ---
; =============================================================================
; INTRARE: AX = numarul de 16 biti de afisat
write_word_as_hex:
    push ax             ; Salvam valoarea originala a lui AX pe stiva
    
    ; Pas 1: Afiseaza octetul superior (AH)
    mov al, ah          ; Mutam octetul de sus in AL, pentru ca 'write_byte_as_hex' se asteapta la el acolo
    call write_byte_as_hex
    
    ; Pas 2: Afiseaza octetul inferior (AL)
    pop ax              ; Restauram valoarea originala a lui AX
                        ; Acum AL contine corect octetul de jos
    call write_byte_as_hex
    
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
