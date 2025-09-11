    ;; -----------------------------------------------------------------
    ;; NU SE TINE CONT DE SEMN (PENTRU PROBLEMA CU OGLINDITUL)
    ;; -----------------------------------------------------------------
    mov eax, [numar]
    mov ecx, [oglindit]
    
    sub eax, ecx        ; Calculeaza N - Oglindit. Rezultatul poate fi negativ.
    
    ; Verificam daca rezultatul este negativ folosind flag-ul de semn (SF)
    jns .e_pozitiv      ; Jump if Not Sign (daca nu e negativ, sari)
    
    neg eax             ; Daca a fost negativ, il facem pozitiv
    
.e_pozitiv:
    mov [rezultat], eax



    ;; -----------------------------------------------------------------
    ;;  FACE OGLINDITUL UNUI NUMAR, IN EAX TREBUIE SALVAT NUMARUL
    ;; -----------------------------------------------------------------

make_oglindit:
    ; in eax este numarul
    xor ecx, ecx;
    mov ebx, 10;
.loop:
    cmp eax, 0
    jz .end;
    xor edx, edx;
    div ebx;
    lea ecx, [ecx*4 + ecx]  ; ECX = ECX * 5
    shl ecx, 1              ; ECX = ECX * 2  (Total: ECX * 10)
    add ecx, edx
    jmp .loop
.end:
    ret