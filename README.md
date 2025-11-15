# Memorie emulată în Assembly Intel x86
Programul permite efectuarea a 4 operații: inserare de fișier cu un id și o dimensiune dată, căutare fisier după id, stergere fișier după id și defragmentare (mutarea fișierelor într-un bloc cât mai compact din memorie). Programul are 2 variante: o variantă cu emularea memoriei sub forma de `vector` (task0) și una sub forma de `matrice` (task1). Pentru detalii consultați [acest fișier.](https://cs.unibuc.ro/~crusu/asc/Arhitectura%20Sistemelor%20de%20Calcul%20(ASC)%20-%20Tema%20Laborator%202024.pdf)

## Instalare
```bash
git clone https://github.com/a-violeta/Assembly-emulated-memory.git
cd Assembly-emulated-memory
gcc -m32 task0.s -o task0 -no-pie
gcc -m32 task1.s -o task1 -no-pie
```

## Utilizare
```bash
./task0
./task1
```

## Functionalități
- Gestionarea fișierelor
- Utilizarea funcțiilor în limbaj de asamblare
