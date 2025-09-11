;;spatiu          db ' ', 0
scrie_spatiu:
    pusha
    mov eax, 4
    mov ebx, [descriptor_out]
    mov ecx, spatiu
    mov edx, 1
    int 80h
    popa
    ret