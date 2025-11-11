# Emulated memory in assembly intel x86
Programul permite efectuarea a 4 operatii: inserare fisier cu un id si o dimensiune data, cautare fisier dupa id, stergere fisier dupa id si defragmentare adica mutarea fisierelor intr un bloc cat mai compact din memorie. Programul are 2 variante: o varianta cu emularea memoriei sub forma de vector (task0) si una sub forma de matrice (task1).

commands:
gcc -m32 task0.s -o task0 -no-pie
gcc -m32 task1.s -o task1 -no-pie
