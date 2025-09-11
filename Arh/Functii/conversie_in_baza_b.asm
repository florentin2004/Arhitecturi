alfabet         db '0123456789ABCDEF'
    mov eax, [numar_de_convertit]
    mov ebx, [baza_noua]

; =============================================================================
; --- Conversia in baza B ---
; =============================================================================
; INTRARE: EAX = numarul de convertit, EBX = baza noua
convert_and_write:
    xor ecx, ecx            ; ECX = contorul de cifre
    ; EAX = numar, EBX = baza
.conversion_loop:
    cmp eax, 0
    je .start_write
    
    xor edx, edx
    div ebx                 ; EAX = cat, EDX = rest
    
    ; EDX contine indexul. Il folosim sa gasim caracterul si punem PE STIVA.
    mov edi, alfabet
    add edi, edx
    movzx edx, byte [edi]
    
    push edx                ; Punem caracterul (ex: 'F') pe stiva.
    inc ecx
    
    jmp .conversion_loop    ; Ne intoarcem cu noul EAX (catul).

.start_write:
    ; La acest punct, stiva contine TOATE caracterele in ordine inversa.
    ; EAX este 0.
    cmp ecx, 0
    je .handle_zero

.write_loop:
    cmp ecx, 0
    je .end_write
    
    dec ecx
    pop edx                 ; Scoatem un CARACTER (ex: 'F') de pe stiva
    mov [caracter], dl
    
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa
    
    jmp .write_loop

.handle_zero:
    mov byte [caracter], '0'
    pusha; mov eax, 4; mov ebx, [descriptor_out]; mov ecx, caracter; mov edx, 1; int 80h; popa

.end_write:
    ret