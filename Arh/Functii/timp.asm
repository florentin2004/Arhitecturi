; INTRARE: EAX = numarul total de secunde
; IESIRE: vectorul 'timp' este populat
;     timp            resd 4
converteste_secunde:
    ; --- Calculeaza SECUNDELE si totalul de MINUTE ---
    mov ebx, 60
    xor edx, edx
    div ebx
    ; EDX = rest (secundele finale), EAX = cat (totalul de minute)
    mov [timp + 12], edx        ; Stocam secundele la timp[3] (index 3 * 4 bytes)
    
    ; --- Calculeaza MINUTELE si totalul de ORE ---
    ; EAX contine deja totalul de minute
    mov ebx, 60
    xor edx, edx
    div ebx
    ; EDX = rest (minutele finale), EAX = cat (totalul de ore)
    mov [timp + 8], edx         ; Stocam minutele la timp[2]
    
    ; --- Calculeaza ORELE si totalul de ZILE ---
    ; EAX contine deja totalul de ore
    mov ebx, 24
    xor edx, edx
    div ebx
    ; EDX = rest (orele finale), EAX = cat (zilele)
    mov [timp + 4], edx         ; Stocam orele la timp[1]
    mov [timp], eax             ; Stocam zilele la timp[0]
    
    ret

; Afiseaza cele 4 componente ale vectorului 'timp'
afiseaza_timp:
    ; Afiseaza zilele
    mov eax, [timp]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza orele
    mov eax, [timp + 4]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza minutele
    mov eax, [timp + 8]
    call integer_to_string_and_write_robust
    call scrie_spatiu
    
    ; Afiseaza secundele
    mov eax, [timp + 12]
    call integer_to_string_and_write_robust
    ret