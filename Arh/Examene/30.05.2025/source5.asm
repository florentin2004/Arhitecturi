;; NU ESTE VARIANTA FINALA. AVEM NISTE PROBLEME
SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out5.txt', 0
    
SECTION .bss
    buffer          resb 200
    descriptor_in   resb 4
    descriptor_out  resb 4
    
    numar1          resb 51
    numar2          resb 51
    rezultat        resb 51
    
    lungime_nr1     resd 1
    caracter        resb 1

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
    mov edx, 200
    int 80h

    ; --- PASUL 2: Pregateste vectorii de numere ---
    mov edi, numar1
    mov ecx, 51
    call umple_cu_zero_bytes
    
    mov edi, numar2
    mov ecx, 51
    call umple_cu_zero_bytes
    
    mov edi, rezultat
    mov ecx, 51
    call umple_cu_zero_bytes
    
    mov esi, buffer
    call parse_numere_mari
    
    ; --- PASUL 3: Executa scaderea ---
    call scade_numere_mari
    
    ; --- PASUL 4: Scrie rezultatul in fisier ---
    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax
    
    call afiseaza_rezultat_cu_padding

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

; =============================================================================
; --- FUNCTII SPECIFICE PROBLEMEI ---
; =============================================================================
parse_numere_mari:
    mov edi, numar1 + 50
    xor ecx, ecx
.loop_nr1:
    mov al, [esi]
    cmp al, 0Ah
    je .gata_nr1
    sub al, '0'
    mov [edi], al
    dec edi
    inc esi
    inc ecx
    jmp .loop_nr1
.gata_nr1:
    mov [lungime_nr1], ecx
    inc esi

    mov edi, numar2 + 50
.loop_nr2:
    mov al, [esi]
    cmp al, 0Ah
    je .gata_nr2
    cmp al, 0
    je .gata_nr2
    sub al, '0'
    mov [edi], al
    dec edi
    inc esi
    jmp .loop_nr2
.gata_nr2:
    ret

scade_numere_mari:
    mov esi, numar1 + 50
    mov edi, numar2 + 50
    mov edx, rezultat + 50
    mov ecx, 51
    clc
.loop_scadere:
    mov al, [esi]
    sbb al, [edi]
    das
    mov [edx], al
    dec esi
    dec edi
    dec edx
    dec ecx
    jnz .loop_scadere
    ret

afiseaza_rezultat_cu_padding:
    mov ecx, [lungime_nr1]
    mov esi, rezultat + 51
    sub esi, ecx
.loop_afisare:
    cmp ecx, 0
    je .gata_afisare
    mov al, [esi]
    add al, '0'
    mov [caracter], al
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    inc esi
    dec ecx
    jmp .loop_afisare
.gata_afisare:
    ret

; =============================================================================
; --- FUNCTII AJUTATOARE (DIN PORTOFOLIU) ---
; =============================================================================
umple_cu_zero_bytes:
.loop_umplere:
    cmp ecx, 0
    je .gata_umplere
    mov byte [edi], 0
    inc edi
    dec ecx
    jmp .loop_umplere
.gata_umplere:
    ret
