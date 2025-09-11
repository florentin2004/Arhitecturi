Ai dreptate, am omis să grupez și operațiile de bază cu fișiere. Le-am tratat ca fiind parte din logica principală (`_start`), dar este o idee excelentă să le ai și pe ele documentate ca "rețete" separate în portofoliul tău.

Iată-le, sub formă de șabloane de cod pe care le poți copia și adapta.

---

### Portofoliu de Operații cu Fișiere

#### 1. `file_open_read.asm` - Deschiderea unui fișier pentru citire

```assembly
; =============================================================================
;   SABLON: Deschiderea unui fisier pentru CITIRE (Read-Only)
; =============================================================================
;   SCOP:
;       Deschide un fisier existent pentru a-i citi continutul.
;
;   PRERECHIZITE:
;       SECTION .data
;           nume_fisier db 'input.txt', 0
;       SECTION .bss
;           descriptor  resb 4
;
;   IESIRE (Output):
;       In variabila 'descriptor' se va stoca file descriptor-ul returnat
;       de sistemul de operare. Daca deschiderea esueaza, valoarea va fi
;       negativa (ex: -1).
; =============================================================================
; --- Exemplu de utilizare in _start ---
    mov eax, 5                  ; Apel de sistem SYS_OPEN
    mov ebx, nume_fisier        ; EBX = adresa numelui de fisier (terminat prin nul)
    mov ecx, 0                  ; ECX = flag-uri de acces. 0 inseamna O_RDONLY (doar citire)
    mov edx, 0                  ; EDX = mod (irelevant la citire, se pune 0)
    int 80h
    
    ; TODO: Ar fi ideal sa verificam daca EAX este negativ (eroare)
    
    mov [descriptor], eax       ; Salvam descriptorul obtinut
```

#### 2. `file_open_write.asm` - Deschiderea/Crearea unui fișier pentru scriere

```assembly
; =============================================================================
;   SABLON: Deschiderea/Crearea unui fisier pentru SCRIERE (Write-Only)
; =============================================================================
;   SCOP:
;       Deschide un fisier pentru a scrie in el. Daca fisierul nu exista,
;       il creeaza. Daca exista, ii suprascrie continutul.
;
;   PRERECHIZITE:
;       SECTION .data
;           nume_fisier db 'output.txt', 0
;       SECTION .bss
;           descriptor  resb 4
;
;   IESIRE (Output):
;       In variabila 'descriptor' se va stoca file descriptor-ul.
; =============================================================================
; --- Exemplu de utilizare in _start ---
    mov eax, 5                  ; Apel de sistem SYS_OPEN
    mov ebx, nume_fisier        ; EBX = adresa numelui de fisier
    mov ecx, 65                 ; ECX = flag-uri. 65 = O_WRONLY (1) | O_CREAT (64)
    mov edx, 0644o              ; EDX = permisiunile fisierului (mod octal)
                                ; 0644o = proprietarul poate citi/scrie, restul doar citi
    int 80h
    
    ; TODO: Verificare eroare (EAX < 0)
    
    mov [descriptor], eax
```

#### 3. `file_read.asm` - Citirea dintr-un fișier deschis

```assembly
; =============================================================================
;   SABLON: Citirea dintr-un fisier deschis
; =============================================================================
;   SCOP:
;       Citeste un numar de octeti dintr-un fisier deja deschis si ii
;       pune intr-o zona de memorie (buffer).
;
;   PRERECHIZITE:
;       - Fisierul trebuie sa fi fost deschis inainte.
;       - Sa existe un file descriptor valid salvat in [descriptor].
;       SECTION .bss
;           descriptor  resb 4
;           buffer      resb 1024       ; O zona de memorie unde sa se puna datele
;
;   IESIRE (Output):
;       EAX: Numarul de octeti care au fost cititi efectiv. Poate fi mai mic
;            decat cel cerut daca am ajuns la finalul fisierului (End-of-File).
;            Daca EAX este 0, inseamna ca nu mai era nimic de citit.
; =============================================================================
; --- Exemplu de utilizare in _start ---
    mov eax, 3                  ; Apel de sistem SYS_READ
    mov ebx, [descriptor]       ; EBX = file descriptor-ul obtinut la deschidere
    mov ecx, buffer             ; ECX = adresa buffer-ului unde se vor stoca datele
    mov edx, 1024               ; EDX = numarul MAXIM de octeti de citit
    int 80h
```

#### 4. `file_write.asm` - Scrierea într-un fișier deschis

```assembly
; =============================================================================
;   SABLON: Scrierea intr-un fisier deschis
; =============================================================================
;   SCOP:
;       Scrie un numar de octeti dintr-o zona de memorie (buffer) intr-un
;       fisier deja deschis.
;
;   PRERECHIZITE:
;       - Fisierul trebuie sa fi fost deschis inainte.
;       - Sa existe un file descriptor valid salvat in [descriptor].
;       SECTION .data
;           mesaj_de_scris  db 'Hello World'
;           len_mesaj       equ $ - mesaj_de_scris  ; Lungimea calculata la asamblare
;
;   IESIRE (Output):
;       EAX: Numarul de octeti scrisi. Daca e diferit de cel cerut, a fost o eroare.
; =============================================================================
; --- Exemplu de utilizare in _start ---
    mov eax, 4                  ; Apel de sistem SYS_WRITE
    mov ebx, [descriptor]       ; EBX = file descriptor-ul
    mov ecx, mesaj_de_scris     ; ECX = adresa datelor de scris
    mov edx, len_mesaj          ; EDX = lungimea datelor de scris
    int 80h
```

#### 5. `file_close.asm` - Închiderea unui fișier

```assembly
; =============================================================================
;   SABLON: Inchiderea unui fisier
; =============================================================================
;   SCOP:
;       Inchide un fisier deschis, eliberand resursele sistemului.
;
;   PRERECHIZITE:
;       - Un file descriptor valid in [descriptor].
;
;   IESIRE (Output): N/A
; =============================================================================
; --- Exemplu de utilizare in _start ---
    mov eax, 6                  ; Apel de sistem SYS_CLOSE
    mov ebx, [descriptor]       ; EBX = file descriptor-ul de inchis
    int 80h
```

Acum ai totul. Un set complet de "rețete" pentru manipularea fișierelor și conversia datelor, pe care le poți combina pentru a rezolva aproape orice problemă de acest tip.
