# Ghid de Supraviețuire Assembly x86 (NASM)

Acest ghid conține concepte de bază, șabloane de cod și "trucuri" esențiale pentru a scrie cod Assembly eficient. Este un rezumat al multor lucruri pe care le-ai descoperit și folosit deja.

## 1. Flag-urile: Inima Procesorului

Majoritatea deciziilor în Assembly se bazează pe starea unor "beculețe" numite flag-uri, aflate în registrul EFLAGS. O instrucțiune (`cmp`, `add`, `sub`, `shr`, etc.) aprinde sau stinge aceste beculețe, iar o instrucțiune de salt (`jz`, `jg`, etc.) se uită la ele pentru a decide dacă sare sau nu.

Cele mai importante sunt:

-   **ZF (Zero Flag):** "Becul de Zero". Se aprinde (`ZF=1`) dacă rezultatul ultimei operații a fost exact zero.
    -   Folosit de: `jz` (Sari dacă e zero), `jnz` (Sari dacă NU e zero), `je` (Sari dacă e egal), `jne` (Sari dacă NU e egal).

-   **CF (Carry Flag):** "Becul de Transport / Împrumut". Are două roluri majore:
    1.  **La adunări/scăderi:** Se aprinde (`CF=1`) dacă o adunare depășește capacitatea registrului (transport) sau dacă o scădere are nevoie de împrumut. Este esențial pentru lucrul cu numere mari.
        -   Folosit de: `adc` (Adună cu Carry), `sbb` (Scade cu Împrumut), `jc` (Sari dacă e Carry), `jnc` (Sari dacă NU e Carry).
    2.  **La shiftări (`shl`, `shr`):** Acționează ca un "coș de gunoi" pentru ultimul bit care este scos din registru.
        -   `shr eax, 1`: Ultimul bit din `eax` este pus în `CF`.
        -   `shl eax, 1`: Ultimul bit din `eax` este pus în `CF`.

-   **SF (Sign Flag):** "Becul de Semn". Se aprinde (`SF=1`) dacă rezultatul ultimei operații este un număr negativ (adică cel mai semnificativ bit este 1).
    -   Folosit de: `js` (Sari dacă e Semn/Negativ), `jns` (Sari dacă Nu e Semn/Pozitiv) și de toate salturile cu semn (`jg`, `jl`, etc.).

## 2. Salturi Condiționate: Cum Luăm Decizii

După o instrucțiune `cmp operand1, operand2`, poți folosi diferite salturi. Alegerea corectă depinde dacă lucrezi cu numere **cu semn** (negative și pozitive) sau **fără semn** (doar pozitive, ex: lungimi, indecși).

| Scop | Fără Semn (Unsigned) | Cu Semn (Signed) | Universal | Flag-uri verificate |
| :--- | :--- | :--- | :--- | :--- |
| `op1 == op2` | `je` (equal) | `je` (equal) | `jz` (zero) | ZF |
| `op1 != op2` | `jne` (not equal) | `jne` (not equal) | `jnz` (not zero)| ZF |
| `op1 > op2`  | `ja` (above) | `jg` (greater) | | SF, ZF, OF |
| `op1 < op2`  | `jb` (below) | `jl` (less) | | SF, OF |
| `op1 >= op2` | `jae` (above or eq)| `jge` (greater or eq)| | SF, ZF, OF |
| `op1 <= op2` | `jbe` (below or eq)| `jle` (less or eq) | | SF, OF |

**Regula de bază:**
-   Dacă lucrezi cu lungimi, adrese, indecși de vector -> Folosește salturi **fără semn** (`ja`, `jb`).
-   Dacă lucrezi cu numere care pot fi negative -> Folosește salturi **cu semn** (`jg`, `jl`).

## 3. Operații Aritmetice Cheie

Aici sunt instrucțiunile de bază și comportamentul lor, în special pentru `MUL`/`DIV`.

-   **`ADD dest, sursa`**: `dest = dest + sursa`.
-   **`SUB dest, sursa`**: `dest = dest - sursa`.
-   **`INC reg/mem`**: `reg = reg + 1`. Mai rapid decât `add reg, 1`.
-   **`DEC reg/mem`**: `reg = reg - 1`. Mai rapid decât `sub reg, 1`.
-   **`NEG reg`**: Schimbă semnul (`reg = -reg`).

### Înmulțirea

-   **`MUL sursa` (Fără Semn):**
    -   Înmulțește `EAX` cu `sursa`.
    -   Rezultatul de 64 de biți este pus în `EDX:EAX`.
    -   **Atenție:** Distruge `EDX`! `xor edx, edx` este necesar înainte.

-   **`IMUL sursa` (Cu Semn):**
    -   Similar cu `MUL`, dar pentru numere cu semn.

-   **`IMUL dest, sursa` (Forma cu 2 operanzi):**
    -   Calculează `dest = dest * sursa`.
    -   Rezultatul este pe **32 de biți**, **ignorând depășirea** (partea superioară care s-ar duce în `EDX`).
    -   **Extrem de util** când îți pasă doar de ultimii 16 sau 32 de biți ai produsului.

-   **`IMUL dest, sursa, valoare` (Forma cu 3 operanzi):**
    -   Calculează `dest = sursa * valoare`.

### Împărțirea

-   **`DIV sursa` (Fără Semn):**
    -   Împarte `EDX:EAX` (un număr de 64 de biți) la `sursa` (32 de biți).
    -   **Câtul** este pus în `EAX`.
    -   **Restul** este pus în `EDX`.
    -   **Atenție:** Trebuie să faci `xor edx, edx` înainte dacă împarți doar `EAX`.

-   **`IDIV sursa` (Cu Semn):**
    -   Similar cu `DIV`, dar pentru numere cu semn.
    -   **Atenție:** Trebuie să faci `cdq` înainte, care extinde semnul lui `EAX` în tot `EDX`.

## 4. Operații pe Biți: Magia la Nivel Jos

-   **`SHL reg, n` (Shift Left):** Înmulțire rapidă cu 2^n.
    -   `shl eax, 1` este echivalent cu `eax = eax * 2`.
    -   `shl eax, 3` este echivalent cu `eax = eax * 8`.
    -   Ultimul bit care "iese" este pus în Carry Flag (CF).

-   **`SHR reg, n` (Shift Right):** Împărțire rapidă (fără semn) la 2^n.
    -   `shr eax, 1` este echivalent cu `eax = eax / 2`.
    -   Ultimul bit care "iese" este pus în Carry Flag (CF).

-   **`AND reg, masca`:** Folosit pentru a "șterge" biți (mascare). Păstrează doar biții care sunt 1 și în registru, și în mască.
    -   Exemplu: `and al, 0x0F` -> păstrează doar ultimii 4 biți din `al`.

-   **`OR reg, masca`:** Folosit pentru a "aprinde" biți. Setează pe 1 biții care sunt 1 în mască, fără a-i afecta pe ceilalți.
    -   Exemplu: `or ecx, 64` -> echivalent cu `O_WRONLY | O_CREAT`.

-   **`XOR reg, masca`:** Folosit pentru a "inversa" biți (toggle) sau pentru a goli un registru.
    -   `xor al, 0b1111` -> Inversează ultimii 4 biți din `al`.
    -   `xor eax, eax` -> Cea mai rapidă metodă de a face `eax = 0`.

-   **`TEST reg, masca`:** Ca un `AND` care nu modifică registrul. Doar setează flag-urile.
    -   Exemplu: `test eax, 1` -> Verifică dacă ultimul bit este 1, fără a schimba `eax`. Setează `ZF=1` dacă ultimul bit era 0.

## 5. Șabloane și Trucuri Utile

### Implementarea unui "Switch"
Folosești o cascadă de `cmp`/`je`. Este exact ce ai făcut la calculator.
```assembly
    mov al, [operator]
    cmp al, '+'
    je .cazul_adunare
    cmp al, '-'
    je .cazul_scadere
    ; ... si asa mai departe
```

### Interschimbarea Valorilor (Swap) - `XCHG`
Când ai nevoie să inversezi rapid valorile a două registre sau a unui registru cu o locație de memorie, `xchg` este cea mai eficientă instrucțiune.
-   **Între două registre:**
    ```assembly
    xchg eax, ebx   ; Acum EAX contine ce era in EBX, si invers.
    ```
-   **Utilizare tipică:** Pregătirea pentru `div`. Dacă vrei să împarți `EBX` la `EAX`:
    ```assembly
    ; Vrem sa facem [numar1] / [numar2]
    mov eax, [numar2]
    mov ebx, [numar1]
    xchg eax, ebx   ; Acum EAX=[numar1], EBX=[numar2]
    div ebx
    ```

### Schimbarea Semnului și Valoarea Absolută
-   **`NEG reg`:** Cea mai simplă metodă de a schimba semnul. Calculează `reg = -reg` (complement de 2).
-   **Valoarea absolută (fără salturi):**
    ```assembly
    ; Calculeaza valoarea absoluta a lui EAX
    cdq                 ; Extinde semnul lui EAX in EDX (EDX devine 0 sau -1)
    xor eax, edx
    sub eax, edx
    ; Acum EAX contine |EAX|
    ```

### Adunare/Scădere pe mai mulți Octeți (Numere Mari)
Rețeta pentru adunarea/scăderea numerelor mari stocate în vectori de cifre BCD.
- **Adunare:** `clc` -> `adc` -> `daa`
- **Scădere:** `clc` -> `sbb` -> `das`

### Înmulțire Rapidă cu Constante
Instrucțiunea `lea` (Load Effective Address) poate fi folosită pentru a face calcule matematice rapide.
-   `eax * 5`: `lea eax, [eax*4 + eax]`
-   `eax * 10`: `lea eax, [eax*4 + eax]` (face `eax*5`), apoi `shl eax, 1` (face `eax*2`).