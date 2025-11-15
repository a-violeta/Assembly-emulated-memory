.data
	memorie: .zero 1024
	formatScanf: .asciz "%d"
	O: .space 4
	cod_operatie: .space 1
	N: .space 4
	fd: .space 1
	dim: .space 4
	formatPrintfADD: .asciz "%d: (%d, %d)\n"
	formatPrintfGET: .asciz "(%d, %d)\n"
	verificare: .space 1
	start: .space 4
	end: .space 4
	defrag: .space 1
				#indice_precedent: .long 0
.text
.global main

show:				#iterare cu ecx, retinere fd in edx, apelare get pt start si end
	push %ebp
	mov %esp, %ebp
	mov $memorie, %esi
	xor %ecx, %ecx
loop_show:
	cmp $1024, %ecx		#DIMENSIUNEA
	je exit_show

	xor %edx, %edx
	movb (%esi, %ecx, 1), %dl	#fd

	cmpb $0, fd		#tot ce e 0 ignoram, nu e defragmentat deci poate nu e final de vect
	je inc_show

	movb $1, defrag
	push %ecx		#%esi nu?
	push %edx
	call GET
	pop %edx
	pop %ecx
	movb $0, defrag		#avem start si end

	push %ecx
	push end
	push start
	push %edx
	push $formatPrintfADD	#afisarea
	call printf
	add $16, %esp

	pop %ecx
	#mov end, %edx
	add end, %ecx
	jmp inc_show
inc_show:
	inc %ecx
	jmp loop_show
exit_show:
	pop %ebp
	ret

redimensionare:			#am apelat cu reg si am facut add 4 si rezultatul era in eax
        push %ebp
        mov %esp, %ebp

        mov 8(%ebp), %eax	#dim

	cmp $0, %eax
	jle redim_exit

        cmp $16, %eax
        jle et_dim_minim	#fis ocupa macar 2 blocuri de memorie, daca e multiplu de 8 l am lasat fix catul

        xor %edx, %edx
        mov $8, %ebx		#avem nevoie la impartire, pot imparti la %bl dar reg ebx tot e ocupat deci degeaba
	div %ebx

        cmp $0, %edx
        je redim_exit

        inc %eax
        jmp redim_exit
et_dim_minim:
	mov $2, %eax
        jmp redim_exit
redim_exit:
	pop %ebp
        ret

ADD:
    	push %ebp
        mov %esp, %ebp
                                #mai departe aleg sa cred ca fd e valid si dim e valid
        mov 12(%ebp), %ebx	#vreau dim in ebx
	xor %edx, %edx
        movb 8(%ebp), %dl	#fd in edx
	movb %dl, fd
        movb $0, verificare     #pt a sti daca v[i]=v[i-1]=0

	cmpb $1, defrag
	je et_fara_redimensionare_ADD
redimensionare_ADD:
        push %ebx
        call redimensionare
        add $4, %esp

	cmp $0, %eax
	jle et_spatiu_insuficient_ADD	#dim neconforma

        mov %eax, %ebx          #dim(in blocuri) e acum si in ebx si in dim                                         #linia 50
        mov %eax, dim
	jmp et_pregatire_loop_ADD
et_fara_redimensionare_ADD:
	mov dim, %ebx
	jmp et_pregatire_loop_ADD
et_pregatire_loop_ADD:
        xor %eax, %eax
                                #push %edx

        mov $memorie, %esi
        xor %edx, %edx

						#cmpb $1, defrag
						#je et_pregatire_loop_suplimentara

	xor %ecx, %ecx
	jmp et_parcurgere_memorie_ADD
					#et_pregatire_loop_suplimentara:
						#mov indice_precedent, %ecx		#la defrag nu vreau sa schimb ordinea fisierelor
						#jmp et_parcurgere_memorie_ADD		#indice_precedent are end+1 al ultimului fis din memorie
et_parcurgere_memorie_ADD:
        cmp $1024, %ecx           #DIMENSIUNE
        je et_afisare_ADD

        movb (%esi, %ecx, 1), %dl            #am v[i]
                                #daca am 0, daca nu e primul 0, inc eax si daca eax==ebx exit parcurgere
        cmpb $0, %dl
        je et_poz_libera_ADD

        movb $0, verificare              #daca v[i] nenul
        jmp et_inc_loop_ADD
et_inc_loop_ADD:
	inc %ecx
        jmp et_parcurgere_memorie_ADD
et_poz_libera_ADD:
	cmpb $0, verificare
        je et_recalculare_ADD

        inc %eax                #else asta nu e primul spatiu liber in vect
        cmp %eax, %ebx
        je et_afisare_ADD

        jmp et_inc_loop_ADD
et_recalculare_ADD:
        mov $1, %eax
        movb $1, verificare
        jmp et_inc_loop_ADD
et_spatiu_insuficient_ADD:                  #n am verificat o
	#cmpb $1, defrag
	#je et_ADD_exit

        xor %ecx, %ecx
                                #pop %edx
        push %ecx
        push %ecx
        movb fd, %cl
        push %ecx                 #fd, edx
        push $formatPrintfADD
        call printf
        add $16, %esp
        jmp et_ADD_exit
et_afisare_ADD:
                                #pop %edx
        cmp dim, %eax
        jl et_spatiu_insuficient_ADD        #n am gasit destule poz cat are dim (ebx)

	#cmpb $1, defrag
	#je et_ADD_fara_afisare

        mov %ecx, %ebx                  #ult poz nula
        sub dim, %ecx                                                                           #linia 100
        inc %ecx                #acum tot ecx are poz
        mov %ecx, %edx

        push %edx                       #dupa apel functie pierd edx

        push %ebx                       #ult poz nula
        push %edx			#prima poz nula
        xor %ecx, %ecx
        movb fd, %cl
        push %ecx                       #fd
        push $formatPrintfADD
        call printf
        add $16, %esp

        pop %edx
        jmp et_adaugarea_ADD
#et_ADD_fara_afisare:
#	mov %ecx, %ebx		#ult poz nula
#	sub dim, %ecx
#	inc %ecx
#	mov %ecx, %edx		#prima po nula
#	jmp et_adaugarea_ADD
et_adaugarea_ADD:                   #se ajunge aici doar daca avem ceva valid, eax are poz start, ebx are end, dl are v[i]
        inc %ebx                #ca sa iau toate valorile

        mov %edx, %ecx
	xor %eax, %eax
	movb fd, %al
et_loop_adaugare_ADD:			#merge pana aici
        cmp %ebx, %ecx
        je et_ADD_exit

        movb %al, (%esi, %ecx, 1)        #v[i]

        inc %ecx
        jmp et_loop_adaugare_ADD
et_ADD_exit:
	pop %ebp
        ret

GET:
    	push %ebp
        mov %esp, %ebp
        movb $0, verificare
	movb 8(%ebp), %al
	movb %al, fd
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        mov $memorie, %esi
et_loop_iterare_GET:
        cmp $1024, %ecx
        je et_afisare_GET

        movb (%esi, %ecx, 1), %dl	#v[i]
        cmpb %dl, fd
        je et_gasit_start_GET
et_loop_continuare_GET:
        inc %ecx
        jmp et_loop_iterare_GET
et_gasit_start_GET:
        cmpb $1, verificare
        je et_gasit_end_GET

        mov %ecx, %eax                  #eax retine poz start
        movb $1, verificare
        jmp et_loop_continuare_GET
et_gasit_end_GET:
        mov %ecx, %ebx                  #ebx retine poz end
        jmp et_loop_continuare_GET
et_afisare_GET:
	cmpb $1, defrag
	je et_GET_fara_afisare

        push %ebx
        push %eax
        push $formatPrintfGET
        call printf
        add $12, %esp
        jmp et_GET_exit			#AICI 200
et_GET_fara_afisare:			#pt defrag
	mov %eax, start
	mov %ebx, end
	jmp et_GET_exit
et_GET_exit:
        pop %ebp
        ret

DELETE:
       	push %ebp
        mov %esp, %ebp
					#xor %ebx, %ebx
        movb 8(%ebp), %bl               #vreau fd aici, oare ramane aici dupa ce efectuez procese?
        mov $memorie, %esi

        xor %ecx, %ecx
et_loop_stergere:
        cmp $1024, %ecx                   #DIMENSIUNEA
        je et_DELETE_exit
					#xor %dl, %dl
        movb (%esi, %ecx, 1), %bh	#v[i]

	push %ecx			#sa nu l pierd

        cmpb %bl, %bh
        je et_stergere

	cmpb $1, defrag
	je et_loop_stergere_continuare

	cmpb $0, %bh
	je et_loop_stergere_continuare

	jmp et_afisare_DEL
et_loop_stergere_continuare:
	pop %ecx
        inc %ecx
        jmp et_loop_stergere
et_afisare_DEL:				#un else la compararea bl si bh
	movb $1, defrag			#impropriu folosit, pur si simplu nu vreau ca get sa afiseze

	#xor %eax, %eax
	#movb %bh, %al

	movb %bh, fd
					#xor %bh, %bh
	push %ebx			#asa pastrez fd de sters in bl, si fd ul curent in bh

	push fd
	call GET			#acum am start si end
	add $4, %esp

	push end
	push start
	push fd
	push $formatPrintfADD
	call printf
	add $16, %esp

	pop %ebx

	movb $0, defrag

	pop %ecx				#trebuie sa incrementez ecx sa sara la urmatorul fisier in functie de dim celui curent afisat
	mov end, %eax				#dim=end-start+1
        sub start, %eax
        inc %eax
	add %eax, %ecx
	jmp et_loop_stergere
et_stergere:
					#pop %ecx
	movb $0, (%esi, %ecx, 1)
					#push %ecx
        jmp et_loop_stergere_continuare
et_DELETE_exit:
        pop %ebp
        ret

DEFRAGMENTATION:
                                        #iterez, pt fiecare fd fac get(fd), aflu dim, delete(fd) si add(fd, dim)
        push %ebp
        mov %esp, %ebp
        xor %ecx, %ecx
        xor %edx, %edx
        movb $1, defrag                 #movb $0, verificare                                                            #linai 200
        mov $memorie, %esi
et_iterare_DEF:
	cmp $1024, %ecx                   #DIMENSIUNE
        je et_exit_DEF

        movb (%esi, %ecx, 1), %dl	#v[i]
        movb %dl, fd                    #nenecesar cred, dar incercam
        cmpb $0, %dl
        je et_inc_DEF
                                #cmpb $0, verificare
                                #je et_dim
                                #movb $1, verificare
        push %ecx                       #pierd indexarea vectorului altfel

        push %edx
        call GET                        #apel functie in functie
                        #et_vezi1:
                                #pop %eax                       #pop rezultatele ca sa am dim
                                #pop %edx
                        #et_vezi2:
        pop %edx

        mov end, %eax                           #am start si end
        sub start, %eax
        inc %eax
        mov %eax, dim                           #am dim

        push %edx
        call DELETE
        pop %edx

        mov dim, %eax
        push %eax
        push %edx
        call ADD
        pop %edx
	add $4, %esp

					#push %edx		#indice_precent ia pozitia imediat urmatoare dupa ultimul fisier adaugat
					#call GET
					#mov end, %ecx
					#inc %ecx
					#mov %ecx, indice_precedent

        pop %ecx
        mov end, %ecx
et_inc_DEF:
	inc %ecx
        jmp et_iterare_DEF
et_exit_DEF:
	movb $0, defrag
        pop %ebp
        ret

main:
        mov $memorie, %esi
et_citire_date:
	push $O
	push $formatScanf
	call scanf
	add $8, %esp			#O = nr de operatii de efectuat
	mov $0, %ecx			#de aici trebuie sa restaurez mereu ecx
et_loop_executare:                      #pana aici merge, mai departe nu. et_loop_executare este mai bine for
	cmp O, %ecx
	je et_exit

	push %ecx			#sa nu pierd counter ul
#300
	push $cod_operatie
	push $formatScanf
	call scanf
	add $8, %esp			#cod_operatie merge

	cmpb $1, cod_operatie
	je et_add
	cmpb $2, cod_operatie
        je et_get
	cmpb $3, cod_operatie
        je et_del
	cmpb $4, cod_operatie
        je et_defrag
et_inc:
	pop %ecx
	inc %ecx
	jmp et_loop_executare

et_add:
	push $N
	push $formatScanf
	call scanf
	add $8, %esp			#am nr de fis

	xor %ecx, %ecx
et_loop_efectuare_ADD:			#merge pana aici
	cmp N, %ecx
	je et_inc

	push %ecx			#sa nu l pierd

	push $fd
	push $formatScanf
	call scanf
	add $8, %esp

	push $dim
        push $formatScanf
        call scanf
        add $8, %esp			#am file descriptor si dim

	push dim
	push fd
	call ADD
	add $8, %esp

	pop %ecx

	inc %ecx
	jmp et_loop_efectuare_ADD

et_get:
	push $fd
	push $formatScanf
	call scanf
	add $8, %esp 			#am fis cautat

	push fd
	call GET
	add $4, %esp

	jmp et_inc

et_del:
	push $fd
	push $formatScanf
	call scanf
	add $8, %esp			#am fis

	push fd
	call DELETE
	add $4, %esp

	jmp et_inc

et_defrag:
	call DEFRAGMENTATION
	jmp et_inc

et_exit:
	pushl $0
	call fflush
	popl %eax

	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
