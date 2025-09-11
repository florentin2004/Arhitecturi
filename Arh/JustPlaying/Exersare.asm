SECTION .data
    ; TODO: Defineste numele fisierului de intrare 'an_nastere.txt'
    fisier_in db "an_nastere.txt"
    ; TODO: Defineste numele fisierului de iesire 'varsta.txt'
    fisier_out db "varsta.txt"
    an_curent dd 2024

SECTION .bss
    ; TODO: Defineste un buffer pentru citire
    buffer resb 100
    ; TODO: Defineste spatiu pentru a salva descriptorii de fisiere (in/out)
    in resb 4
    out resb 4
    ; TODO: Defineste un buffer de 1 byte pentru afisarea cifrelor
    cifra_buffer resb 1

SECTION .text
global _start

_start:
    ; === PASUL 1: Deschide si citeste fisierul de intrare ===
    ; TODO: Implementeaza logica pentru a deschide 'an_nastere.txt'
    mov eax, 5
    mov ebx, fisier_in
    mov ecx, 0
    mov edx, 0
    int 80h
    ; TODO: Salveaza descriptorul de fisier
    mov [in], eax
    ; TODO: Implementeaza logica pentru a citi continutul fisierului in buffer
    
    mov eax, 5
    mov ebx, [in]
    mov ecx, buffer
    mov edx, 100
    int 80h

    mov esi, buffer
citeste_numar_din_buffer:
    xor eax, eax
    
.loop:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl .end
    cmp ecx, '9'
    jg .end
    imul eax, 10
    sub ecx, '0'
    add eax, ecx

.end
    ret
    

afiseaza_numar_in_fisier:
    mov ebx, 10
    xor ecx, ecx
extrage_cifre_loop:
    xor edx, edx
    div ebx
    add edx, '0'
    push edx
    inc ecx
    cmp eax, 0
    jne extrage_cifre_loop

afiseaza_cifre_loop:
    cmp ecx, 0
    je end_afisare
    dec ecx
    pop edx
    mov [cifra_buffer], dl
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, cifra_buffer
    mov edx, 1
    int 80h
    popa
    jmp afiseaza_cifre_loop
end_afisare:
    ret
    ; === PASUL 2: Converteste textul in numar si calculeaza varsta ===
    ; TODO: Muta adresa buffer-ului in ESI
    ; TODO: Apeleaza functia 'citeste_numar_din_buffer'
    ;       (Anul nasterii va fi acum in EAX)
    ; TODO: Calculeaza varsta: an_curent - an_nastere. 
    ;       Poti face asta aducand anul curent in EBX si folosind 'sub ebx, eax'.
    ;       Rezultatul (varsta) va fi in EBX.
    ; TODO: Muta rezultatul in EAX pentru a-l pasa functiei de afisare.
    
    ; === PASUL 3: Deschide fisierul de iesire si scrie rezultatul ===
    ; TODO: Salveaza varsta (din EAX) pe stiva pentru a nu o pierde.
    ; TODO: Implementeaza logica pentru a deschide 'varsta.txt' (mod scriere/creare)
    ; TODO: Salveaza descriptorul fisierului de iesire
    ; TODO: Recupereaza varsta de pe stiva inapoi in EAX.
    ; TODO: Apeleaza functia 'afiseaza_numar_in_fisier'

    ; === PASUL 4: Inchide fisierele si iesi din program ===
    ; TODO: Inchide fisierul de intrare
    ; TODO: Inchide fisierul de iesire
    ; TODO: Implementeaza logica de exit (SYS_EXIT)

; ======================================================================
; --- Aici scrie cele doua functii, din memorie pe cat posibil ---

; TODO: Scrie functia 'citeste_numar_din_buffer'
; HINT: Primeste pointer in ESI, returneaza rezultat in EAX.
;       Foloseste o bucla, inmultirea cu 10, si scaderea lui '0'.

; TODO: Scrie functia 'afiseaza_numar_in_fisier'
; HINT: Primeste numar in EAX, returneaza... nimic.
;       Foloseste o bucla cu impartiri la 10 si stiva pentru a inversa cifrele.
;       La final, scrie in fisier folosind descriptorul salvat.
; ======================================================================