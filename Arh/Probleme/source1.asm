; =============================================================================
;   XOR Encryptor - Varianta finala, corectata si lizibila
; =============================================================================

SECTION .data
    nume_fisier_in  db 'in1.txt', 0
    nume_fisier_out db 'out1.txt', 0
    hex_chars       db '0123456789ABCDEF'

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    text_clar       resb 51
    cheie           resb 2
    lungime         resb 1
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

    ; --- PASUL 2: Parseaza textul si cheia din buffer ---
    mov esi, buffer
    mov edi, text_clar
.copiere_text:
    mov al, [esi]
    cmp al, 0Ah
    je .text_copiat
    mov [edi], al
    inc esi
    inc edi
    jmp .copiere_text

.text_copiat:
    mov byte [edi], 0
    inc esi

    mov al, [esi]
    mov [cheie], al
    inc esi
    mov al, [esi]
    mov [cheie + 1], al

    ; --- PASUL 3: Cripteaza textul si calculeaza lungimea ---
    mov esi, text_clar
    xor ecx, ecx
.xor_loop:
    mov al, [esi]
    cmp al, 0
    je .xor_terminat
    
    mov bl, [cheie]
    mov bh, [cheie + 1]
    
    test ecx, 1
    jz .xor_par
    
    xor al, bh
    jmp .xor_continua
.xor_par:
    xor al, bl
.xor_continua:
    mov [esi], al
    inc esi
    inc ecx
    jmp .xor_loop

.xor_terminat:
    mov [lungime], cl

    ; --- PASUL 4: Deschide fisierul de iesire si scrie rezultatul in HEX ---
    mov eax, 5
    mov ebx, nume_fisier_out
    mov ecx, 65
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax

    mov esi, text_clar
    movzx ecx, byte [lungime]
.write_hex_loop:
    cmp ecx, 0
    je .gata_scrierea
    
    movzx eax, byte [esi]
    
    push ecx
    push esi
    call write_byte_as_hex
    pop esi
    pop ecx
    
    inc esi
    dec ecx
    jmp .write_hex_loop

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

; ======================================================================
; --- FUNCTIA: Scrie un octet (din AL) ca doua caractere HEX ---
; ======================================================================
write_byte_as_hex:
    push eax
    
    ; Proceseaza prima jumatate (high nibble)
    shr al, 4
    mov ebx, hex_chars
    add ebx, eax
    mov cl, [ebx]
    mov [caracter], cl
    
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    
    pop eax
    
    ; Proceseaza a doua jumatate (low nibble)
    and al, 0x0F
    mov ebx, hex_chars
    add ebx, eax
    mov cl, [ebx]
    mov [caracter], cl
    
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    
    ret
