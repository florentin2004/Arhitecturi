numar_de_biti_1:
    ; INTRARE: EAX = numarul de verificat
    ; IESIRE: ECX = numarul de biti de 1
    
    xor ecx, ecx        ; Contorul de biti, initial 0
.loop:
    cmp eax, 0          ; Daca numarul a ajuns la 0, am terminat
    je .end
    
    ; Verificam ultimul bit
    test eax, 1
    jz .bit_este_zero   ; Daca ultimul bit E ZERO, sarim peste incrementare
    
    ; Daca am ajuns aici, inseamna ca ultimul bit a fost 1
    inc ecx
    
.bit_este_zero:
    shr eax, 1          ; Trecem la urmatorul bit (impartim la 2)
    jmp .loop           ; Si reluam procesul
.end:
    ret



numar_de_biti_1_compact:
    xor ecx, ecx
.loop:
    cmp eax, 0
    je .end
    
    shr eax, 1      ; Deplaseaza bitii. Ultimul bit ajunge in CF.
    jnc .loop       ; Jump if Not Carry. Daca CF=0 (bitul era 0), sari direct la urmatoarea iteratie.
    
    ; Daca am ajuns aici, inseamna ca CF=1 (bitul era 1)
    inc ecx
    
    jmp .loop
.end:
    ret