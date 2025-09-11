SECTION .data
    nume_fisier_in  db 'in.txt', 0
    nume_fisier_out db 'out3.txt', 0

SECTION .bss
    buffer          resb 100
    descriptor_in   resb 4
    descriptor_out  resb 4
    lungime         resd 1
    caracter        resb 1
    numar           resd 1
    oglindit        resd 1
    rezultat        resd 1

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
    mov [lungime], eax ; Salvam lungimea (nu e folosita, dar e o practica buna)

    mov eax, 5                  ; Apel de sistem SYS_OPEN
    mov ebx, nume_fisier_out
    mov ecx, 65                 ; O_WRONLY | O_CREAT
    mov edx, 0644o
    int 80h
    mov [descriptor_out], eax

    ; --- PASUL 2: Parseaza si Calculeaza ---
    mov dword [buffer + eax], 0 ; Adaugam terminator nul
    mov esi, buffer

    call string_to_integer
    mov [numar], eax
    
    call make_oglindit
    mov [oglindit], ecx
    
    mov eax, [numar]
    mov ecx, [oglindit]
    
    cmp eax, ecx
    jge .scadere1
    jl .scadere2
    
.scadere1:
    sub eax, ecx
    mov [rezultat], eax
    jmp .pasfinal

.scadere2:
    sub ecx, eax
    mov [rezultat], ecx

.pasfinal:
    mov eax, [rezultat]
    call integer_to_string_and_write_robust

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

; =============================================================================
; --- FUNCTIILE TALE ---
; =============================================================================

string_to_integer:
    xor eax, eax
.loop_sti:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl .end_sti
    cmp ecx, '9'
    jg .end_sti
    lea eax, [eax*4 + eax]
    shl eax, 1
    sub ecx, '0'
    add eax, ecx
    inc esi
    jmp .loop_sti
.end_sti:
    ret

make_oglindit:
    xor ecx, ecx
    mov ebx, 10
.loop_oglindit:
    cmp eax, 0
    je .end_oglindit
    xor edx, edx
    div ebx
    lea ecx, [ecx*4 + ecx]
    shl ecx, 1
    add ecx, edx
    jmp .loop_oglindit
.end_oglindit:
    ret

integer_to_string_and_write_robust:
    mov ebx, 10
    xor ecx, ecx
.r_conversion_loop:
    xor edx, edx
    div ebx
    add edx, '0'
    push edx
    inc ecx
    cmp eax, 0
    jne .r_conversion_loop

.r_write_loop:
    cmp ecx, 0
    je .r_end

    dec ecx
    pop edx
    mov [caracter], dl  ; Folosim buffer-ul intermediar

    pusha                   ; Salvam tot inainte de syscall
    mov eax, 4
    ; Aici primim file descriptor-ul in EBX de la apelant
    mov ebx, [descriptor_out] ; Exemplu de cum ar fi folosit
    mov ecx, caracter
    mov edx, 1
    int 80h
    popa                    ; Restauram tot
    jmp .r_write_loop

.r_end:
    ret
