## Curs 1: Domain Name System (DNS)

**Concept și Mod de Utilizare:** DNS este un sistem de baze de date distribuite, cu arhitectură client/server, care realizează conversia între numele de domenii (ex. mta.ro) și adresele IP (ex. 192.124.249.79), facilitând navigarea umană. Funcționează peste protocolul **UDP, portul 53**.

* **Forward DNS:** Conversia din Nume în IP.
* **Reverse DNS:** Conversia din IP în Nume.

**Ierarhia DNS:**

* **Root:** Nivelul suprem al ierarhiei.
* **Top Level Domain (TLD):**
* *gTLD (Generic):* Domenii generale, neasociate unei țări (.com, .org, .edu).
* *ccTLD (Country-Code):* Domenii de 2 litere asociate unei țări (.ro, .uk). Necesită dovezi de reședință.
* *nTLD / lTLD:* Domenii de nișă (.cars) sau domenii în retragere (legacy).


* **Second Level Domain (SLD):** Organizația care a înregistrat domeniul (ex. mta.ro). În anumite țări indică tipul (ex. .ac.uk).
* **Subdomeniu:** Nelimitate, configurate la latitudinea administratorului (ex. acs.upb.ro).

**Fișierul `hosts.txt` (Sistemul anterior și locațiile sale):**

Înainte de apariția DNS, sistemul folosește fișierul `hosts.txt` local, ale cărui căi de localizare sunt:

* **Windows:** `Windows\System32\Drivers\etc\hosts`
* **Linux:** `/etc/hosts`
* *Avantaje:* Ușor de configurat, nu necesită infrastructură suplimentară.
* *Dezavantaje:* Nu este scalabil, nu este dinamic, necesită timp pentru actualizare manuală și generează probleme de unicitate.

**Componente și Mod de Operare:**

* **Server DNS:** Răspunde la cereri (query-uri) și conține înregistrări de resurse (RR - Resource Records).
* **Resolver:** Clientul DNS care trimite cererile (ex. configurat în `/etc/resolv.conf`).
* **Tipuri de cereri (Queries):**
* **Recursiv:** Clientul cere rezoluția completă; serverul își asumă căutarea în numele clientului până găsește răspunsul.
* **Iterativ:** Serverul nu caută mai departe, ci răspunde cu un *referral* (pointer către un alt server ierarhic), iar clientul trebuie să trimită o nouă cerere acolo.



**Tipuri de Înregistrări (Resource Records - RR):** A / AAAA, CNAME, MX, NS, PTR, SOA, TXT.

**Cache și Time to Live (TTL):** Memorie cache cu un **Time to Live (TTL)** ajustabil (5 minute pentru modificări frecvente, 4-24 ore pentru stabilitate), eliminând congestionarea.

---

## Curs 2: Web Servers

**Concept:** Software și hardware capabil să accepte solicitări HTTP de la clienți (browsere) și să ofere răspunsuri cu conținut HTML sau obiecte multimedia.

**Clasificări:**

* **Static vs. Dinamic:** Servere Statice oferă conținut nemodificat (timp de procesare foarte scurt); Servere Dinamice generează conținut adaptat utilizatorului extrăgând date din baze de date (procesare mai lentă, complexitate SW/HW mare).
* **Kernel-mode vs. User-mode:**
* *Kernel-mode* (ex. TUX, IIS): Rapid, folosește direct resursele sistemului (CPU, memorie non-paged).
* *User-mode* (ex. Apache): Până la 6 ori mai lent, trebuie să solicite permisiuni OS pentru resurse și să copieze date în buffere proprii.



**Protocolul HTTP:**

* Procesează **Mesaje Request** (Metode: GET, POST, HEAD, OPTIONS) și **Mesaje Response** (Coduri: 1xx Info, 2xx Succes, 3xx Redirecționare, 4xx Eroare Client, 5xx Eroare Server).
* **Arhitecturi de procesare:**
* *Concurrent/Thread-based:* Multi-process (procese părinte/copil), Multi-threaded, sau Hibrid.
* *SPED (Single-Process-Event-Driven):* Rezolvă o cerere pe rând, extrem de eficient pentru conexiuni concurente.



**Limitări, Cauze și Soluții (Overload):**

* **Network Overload:** Cauzat de trafic imens legitim, DDoS, Worms sau XSS. *Soluții:* Caching client-side, compresie, mărire bandă, utilizare CDN, Load balancing.
* **Memory / CPU Overload:** *Soluții SW:* Optimizare bucle/funcții, folosire Hash Tables, limitare cache, golire variabile. *Soluții HW:* Înlocuire server, Load balancing.
* **I/O Overload:** *Soluții:* Reducere citiri/scrieri DB, discuri mai rapide, optimizare RAID.

**Tipuri Populare de Servere Web:** Apache, Nginx, LiteSpeed, Microsoft IIS, Cloudflare (Pingora).

---

## Curs 3: Mail (Protocoale E-mail)

**Concept:** Transmiterea de mesaje electronice între sursă și destinație printr-o rețea.

**Componentele Arhitecturii:**

* **MUA (Mail User Agent):** Clientul utilizatorului (Outlook, Thunderbird). Pregătește mesajul și creează "plicul" (envelope).
* **MTA (Mail Transfer Agent):** Serverul de transport (Exchange, Postfix). Transferă mailul între rețele. Stochează temporar mesajele dacă destinația e offline (Queue).
* **MSA (Mail Submission Agent):** Port 587. Preia mailul de la MUA, aplică corecții minore și filtrează spam-ul înainte de MTA.
* **MDA (Mail Delivery Agent):** Livrează mailul în căsuța locală a utilizatorului final.
* **Relay / Gateway:** Transmite mailul mai departe (Relay) sau face translare de protocol de la NON-SMTP la SMTP (Gateway).

**SMTP (Simple Mail Transfer Protocol):**

* **Porturi:** **25** (comunicații MTA-MTA necriptate), **465** (SSL), **587** (TLS / MSA).
* **Mod de operare:** End-to-End (între organizații diferite) și Store-and-Forward (în interiorul aceleiași organizații).
* **Comenzi de bază:** `HELO`/`EHLO`, `MAIL FROM`, `RCPT TO`, `DATA`, `QUIT`, `RSET`, `VRFY`.

**Recepția (Pull Protocols):**

* **POP (Post Office Protocol v3):** Port **110**. Descarcă mailurile local și le șterge de pe server.
* **IMAP (Internet Message Access Protocol):** Porturile **143** (pentru conexiuni standard / necriptate) și **993** (pentru IMAP over SSL/TLS). Menține mailurile pe server, oferind sincronizare perfectă pe multiple dispozitive.



---

## Curs 4: Autentificare

**Axa Securității:** Identificare, Autentificare, Autorizare, Auditare (Logging), Accountability (Responsabilitate).

**Factorii Autentificării:**

* **Ce știi (Secret-based):** Parole, PIN. *Atenție:* Stocare obligatorie prin Hashing (niciodată în clar).
* **Ce ai (Token-based):** Smartcard, USB key, Telefon pentru OTP (One Time Passwords - Challenge-Response, Synchronised Clocks).
* **Ce ești (Biometrics):** Amprente, Față, Iris, Retină. *Atenție:* Semnătura olografă, vocea și mirosul NU sunt recomandate pentru autentificare IT.

**Protocoale de Autentificare și AAA:**

* **TACACS+:** Cisco / **TCP port 49**. Separație completă AAA, criptează întregul pachet.
* **RADIUS:** Standard deschis / **UDP port 1812/1813**. Criptează doar parola, combină autentificarea și autorizarea.
* **Kerberos:** Utilizează TGT (Ticket Granting Ticket) și Service Tickets. Arhitectura include Key Distribution Center (KDC) format din Authentication Server (AS) și Ticket Granting Server (TGS).
* **LDAP:** Folosit pentru directoare de date; Binding simplu sau SASL.



---

## Curs 5: Network Security - Proxy & Web Caching

**Concepte Proxy:**
Proxy-ul este un intermediar între client și Internet. Oferă economie de lățime de bandă (caching), securitate, ocolirea restricțiilor și ascunderea adresei IP.

**Clasificarea Proxy-urilor:**

* **După Direcție:** Forward Proxy (protejează clienții din interior) și Reverse Proxy (protejează serverele, load-balancing).
* **După Anonimitate:** Transparent, Anonymous, High Anonymity (Elite), Distorting.
* **După Sursă (IP-uri):** Data Center, Residential, Mobile.

**Web Caching (Stocarea obiectelor pentru accelerare):** Browser Cache (Local), Proxy Cache (Intermediar), Server Cache (Reverse Proxy cache).

---

Iată conținutul complet și detaliat pentru **Cursul 5: Network Security (Proxy, Web Caching, ACL și Firewall)**, structurat curat și organizat pentru a putea fi actualizat direct:

---

## Curs 5: Network Security – Proxy, Web Caching, Firewall & ACL

### 1. Concepte de Proxy și Web Caching

#### 1.1. Ce este un Proxy?

Un server proxy este un intermediar software sau hardware poziționat între un client și rețeaua Internet. Acesta oferă beneficii precum economie de lățime de bandă (prin caching), securitate, ocolirea restricțiilor și mascarea adresei IP a clientului. Spre deosebire de un VPN, **un proxy clasic nu criptează în mod nativ întregul trafic**.

#### 1.2. Clasificarea Proxy-urilor

* **După Direcție:**
* *Forward Proxy:* Poziționat în fața clienților din interiorul rețelei; asigură anonimitate și arhitectură de tip *single-point-of-entry*.


* *Reverse Proxy:* Poziționat în fața serverelor web; realizează *load-balancing*, ascunde serverele reale, blochează atacuri DoS/DDoS și este invizibil pentru clienți.




* **După Nivelul de Anonimitate:**
* *Transparent:* Nu ascunde adresa IP reală a clientului și indică faptul că este un proxy.


* *Anonymous:* Ascunde IP-ul clientului, dar informează serverul țintă că este utilizat un proxy.


* *High Anonymity (Elite):* Șterge toate antetele de identificare și poate schimba periodic adresa IP; este cel mai sigur tip de proxy.


* *Distorting:* Se prezintă ca proxy, dar transmite un IP fals (modifică antetul `X-Forwarded-For`).




* **După Protocol:** HTTP/HTTPS, SOCKS, SIP, SMTP, FTP, DHCP și DNS Proxy.


* **După Sursă (IP-uri):** Data Center Proxy, Residential Proxy (Static sau Rotating) și Mobile Proxy (3G/4G/5G).



#### 1.3. Web Caching

Web caching presupune stocarea locală a copiilor obiectelor web accesate frecvent pentru a reduce timpul de răspuns și încărcarea rețelei.

* **Locații:** Browser Cache, Proxy Cache (Isolated sau Cooperative: ierarhic/non-ierarhic) și Server Cache.


* **Consistența Cache-ului:**
* *Push:* Serverul notifică activ proxy-urile la orice modificare (invalidate sau update).


* *Pull:* Proxy-ul verifică periodic serverul prin interogări de tip *poll* (folosind antetul `if-modified-since`).


* *Hybrid (Leases):* Durata de valabilitate a cache-ului este negociată pe baza vechimii, frecvenței sau încărcării serverului.





---

### 2. Securitatea Rețelelor, Arhitecturi și ACL (Access Control List)

#### 2.1. Arhitecturi de Securizare a Infrastructurii

* **Single Router Approach:** Un singur router de margini (*edge router*) filtrează traficul între rețeaua internă și Internet; poate constitui un punct unic de eșec (*SPOF*).


* **Defense-in-Depth Approach:** Utilizează niveluri multiple de apărare (Edge Router $\rightarrow$ Firewall $\rightarrow$ Internal Router).


* **DMZ (Demilitarized Zone):** O zonă izolată între routere sau interfețe dedicate firewall-ului unde sunt amplasate servere cu expunere publică (ex. Web sau Mail Server).



#### 2.2. Access Control List (ACL)

ACL-ul este o listă ordonată de reguli aplicată pe routere/dispozitive de rețea pentru a permite sau respinge pachete pe baza antetelor de rețea și transport. Regula implicită la sfârșitul oricărui ACL este **Deny All**.

* **Nivel de operare:** Filtrează traficul la **Nivelul 3 (Rețea - IP)** și **Nivelul 4 (Transport - Porturi/Protocoale)**.


* **Tipuri de ACL:**
* *Standard (Interval numerotat 1–99 sau 1300–1999):* Filtrează exclusiv pe baza adresei IP sursă. Se aplică **cât mai aproape de destinație**.


* *Extended (Interval numerotat 100–199 sau 2000–2699 / Named ACL):* Filtrează după protocol, adresă IP sursă, adresă IP destinație și porturi TCP/UDP. Se aplică **cât mai aproape de sursă**.




* **Wildcard Mask:** Reprezintă complementul unei măști de subrețea (biții de `0` înseamnă potrivire obligatorie - *match*, iar biții de `1` înseamnă ignorare - *ignore*). Cuvinte-cheie frecvente: `host` (echivalent wildcard `0.0.0.0`) și `any` (echivalent wildcard `255.255.255.255`).


* **Direcție de aplicare:** *Inbound ACL* (înainte de rutare) sau *Outbound ACL* (după rutare).



---

### 3. Firewall-uri: Clasificare și Arhitecturi

Un firewall este un sistem dedicat controlului politicilor de acces între rețele, fiind poziționat pe singurul punct de tranzit dintre mediul intern de încredere și cel extern/public.

#### 3.1. Clasificarea Firewall-urilor în Funcție de Nivelurile Modelului OSI

* **Nivelul 3 (Rețea) și Nivelul 4 (Transport):**
* *Packet Filtering (Stateless) Firewall:* Inspectează pachetele izolate pe baza IP-urilor, porturilor și protocoalelor, fără a ține cont de starea sau contextul conexiunii.




* **Nivelul 3 (Rețea), Nivelul 4 (Transport) și Nivelul 5 (Sesiune):**
* *Stateful Firewall:* Menține o tabelă de stare (*state table*). Analizează fluxul conexiunii și știe dacă un pachet face parte dintr-o sesiune TCP/UDP legitimă deja stabilită.




* **Nivelul 3, 4, 5 și Nivelul 7 (Aplicație):**
* *Application Gateway / Proxy Firewall / WAF (Web Application Firewall):* Acționează ca intermediar și examinează fluxul de date la nivel de aplicație (trafic HTTP/HTTPS, API-uri). Protejează împotriva atacurilor specifice web (ex. SQL Injection, XSS). Modele de securitate utilizate: *Positive* (Whitelist), *Negative* (Blacklist) și *Mixed*.




* **Inspecție avansată multidimensională:**
* *NGFW (Next-Generation Firewall):* Include inspecție profundă a pachetelor (*Deep Packet Inspection*), sistem de prevenire a intruziunilor integrat (*IPS*), control granular al aplicațiilor și *sandboxing*.




* **Alte tipuri:**
* *Host-based Firewalls:* Software instalat pe stații individuale (ex. Windows Defender Firewall, iptables, nftables).


* *FWaaS (Firewall-as-a-Service):* Soluții de filtrare rulate și livrate complet din cloud.





#### 3.2. IDS vs. IPS

* **IDS (Intrusion Detection System):** Monitorizează traficul și generează alerte la detectarea unei activități suspecte; este plasat în afara fluxului direct (*out-of-band* / port SPAN), neintroducând latență și neputând bloca activ pachetele.


* **IPS (Intrusion Prevention System):** Plasat direct pe calea de trafic (*inline*); detectează și **blochează automat** traficul malițios, sporind securitatea dar introducând un mic overhead de procesare și devenind punct critic de potențial eșec.



#### 3.3. Zone-Based Policy Firewall (ZPF)

O metodă modernă de configurare pe echipamentele Cisco în care interfețele sunt grupate în **Zone de Securitate**:

* Traficul dintre două zone diferite este **blocat în mod implicit**.


* Configurarea folosește componente precum: *class-map* (definirea tipului de trafic vizat), *policy-map* (stabilirea acțiunilor: `inspect`, `drop`, `pass`) și *zone-pair* (asocierea politicii pe direcția între o zonă sursă și o zonă destinație).