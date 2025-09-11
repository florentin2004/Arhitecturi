SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out1.txt', 0
    sir_vocale db 'AEIOUaeiou', 0
    egalitate db "egalitate",0
    consoane db "consoane", 0
    vocale db "vocale",0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resd 1

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
    mov [lungime], eax

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
    ; am pus 0 la sfarsit sa stiu ca am terminat
    mov edi, sir_vocale
    call calculeaza_vocala_consoane
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

calculeaza_vocala_consoane:
    xor ecx, ecx            ; ECX = contorul de vocale
    xor ebx, ebx            ; EBX = contorul de consoane

.loop_calc:
    movzx eax, byte[esi]    ; Ia un caracter
    cmp al, 0
    je .end_calc
    push ebx
    call este_vocala        ; Functia va returna in EDX: 1 daca e vocala, 0 daca nu
    pop ebx
    cmp edx, 1
    je .este_o_vocala
    
.este_o_consoana:
    inc ebx
    jmp .continua_calc

.este_o_vocala:
    inc ecx
    
.continua_calc:
    inc esi
    jmp .loop_calc
    
.end_calc:
    ret

; Functie care verifica daca un caracter este vocala
; INTRARE: AL = caracterul de verificat
; IESIRE: EDX = 1 daca este vocala, 0 altfel
este_vocala:
    mov edi, sir_vocale     ; Resetam pointerul la inceputul dictionarului de vocale
    xor edx, edx            ; Rezultatul (EDX) este initial 0 (nu e vocala)

.loop_este_vocala:
    mov bl, [edi]
    cmp bl, 0
    je .end_este_vocala     ; Daca am ajuns la finalul sir_vocale, nu am gasit-o
    
    cmp al, bl
    je .vocala_gasita       ; Daca am gasit-o, sari
    
    inc edi
    jmp .loop_este_vocala

.vocala_gasita:
    mov edx, 1              ; Setam rezultatul pe 1

.end_este_vocala:
    ret

afisare_rezultat:
    cmp ecx, ebx
    je .egalitate
    jl .consoane
    jg .vocale
.egalitate:
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, egalitate     ; ECX = adresa datelor de scris
    mov edx, 9          ; EDX = lungimea datelor de scris
    int 80h
    jmp .end;
.consoane:
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, consoane    ; ECX = adresa datelor de scris
    mov edx, 8          ; EDX = lungimea datelor de scris
    int 80h
    jmp .end;

.vocale:
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor_out]       ; EBX = file descriptor-ul
    mov ecx, vocale    ; ECX = adresa datelor de scris
    mov edx, 6          ; EDX = lungimea datelor de scris
    int 80h
.end:
    ret

