.data
	memorie: .zero 1048576
	formatScanf: .asciz "%d"
	formatScanfConcrete: .asciz "%s"
	O: .space 4
	cod_operatie: .space 1
	N: .space 4
	fd: .space 1
	dim: .space 4
	formatPrintfADD: .asciz "%d: ((%d, %d), (%d, %d))\n"
	formatPrintfGET: .asciz "((%d, %d), (%d, %d))\n"
	verificare: .space 1
	start: .long 0
	end: .long 0
	i: .space 4
	j: .space 4
	defrag: .space 1
	linia: .space 4
	sf_fis_precedent: .long 0
	path: .space 128
	path_fis: .space 128
	formatError1: .asciz "error procesare fis\n"
	formatError2: .asciz "error concrete\n"
	simbol: .ascii "/"				#nefolosit
	buffer: .space 1024
.text
.global main

redimensionare:
        push %ebp
        mov %esp, %ebp

        mov 8(%ebp), %eax	#dim

	cmp $0, %eax
	jle redim_exit

        cmp $16, %eax
        jle et_dim_minim	#fis ocupa macar 2 blocuri de memorie, daca e multiplu de 8 l am lasat exact catul

        xor %edx, %edx
        mov $8, %ebx		#pt impartire
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

indexare:			#foloseste eax, ebx, edx
	push %ebp
	mov %esp, %ebp

	mov 8(%ebp), %eax	#indexul intreg

	xor %edx, %edx
	mov $1024, %ebx		#DIMENSIUNE LINIE
	div %ebx

	mov %edx, j		#posibil nenecesar
	mov %eax, i
indexare_end:
	pop %ebp
	ret

ADD:
				#dim > 1024 rezulta spatiu insuficient
    	push %ebp
        mov %esp, %ebp
                                #mai departe aleg sa cred ca fd si dim sunt valide
        mov 12(%ebp), %ebx	#dim in ebx

	xor %edx, %edx
        movb 8(%ebp), %dl	#fd si in edx
	movb %dl, fd

	cmp $0, %ebx
	jle et_spatiu_insuficient_ADD	#dim nu e conforma

        movb $0, verificare     #pt v[i]=v[i-1]=0

	cmpb $1, defrag
	je et_fara_redimensionare_ADD
redimensionare_ADD:
        push %ebx
        call redimensionare
        add $4, %esp

	cmp $0, %eax
	jle et_spatiu_insuficient_ADD	#dim nu e conforma

        mov %eax, %ebx          #dim (in blocuri) e in ebx si in dim
        mov %eax, dim
	jmp et_pregatire_loop_ADD
et_fara_redimensionare_ADD:
	mov dim, %ebx
	jmp et_pregatire_loop_ADD
et_pregatire_loop_ADD:
        xor %eax, %eax
        mov $memorie, %esi
        xor %edx, %edx

	cmpb $1, defrag
	je et_pregatire_loop_ADD_suplimentara

        xor %ecx, %ecx
	jmp et_parcurgere_memorie_ADD
et_pregatire_loop_ADD_suplimentara:
	mov sf_fis_precedent, %ecx
	jmp et_parcurgere_memorie_ADD
et_parcurgere_memorie_ADD:
        cmp $1048576, %ecx           #DIMENSIUNE
        je et_afisare_ADD

        movb (%esi, %ecx, 1), %dl	#am v[i]
					#daca am 0, daca inainte nu am 0 e recalculare. altfel inc eax
					#recalculeaza eax daca indexarea ne spune ca am depasit linia sau verificare indica poz nenula inaintea sa
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

	push %ebx
	push %edx
	push %eax
	push %ecx
	call indexare
	pop %ecx
	pop %eax
	pop %edx
	pop %ebx

	push %edi
	mov linia, %edi
	cmp i, %edi			#verific daca indexul i al lui start corespunde cu indexul i curent al lui ecx, daca nu, recalculare
	pop %edi
	jne et_recalculare_ADD

        inc %eax               		#else: asta nu e primul spatiu liber in vect
        cmp %eax, %ebx
        je et_afisare_ADD

        jmp et_inc_loop_ADD
et_recalculare_ADD:
        mov $1, %eax

	push %ebx
	push %edx
	push %eax
	push %ecx
	call indexare
	pop %ecx
	mov %eax, linia			#retine indexul i al pozitiei de start
	pop %eax
	pop %edx
	pop %ebx

        movb $1, verificare
        jmp et_inc_loop_ADD
et_spatiu_insuficient_ADD:
        xor %ecx, %ecx

        push %ecx
	push %ecx
	push %ecx
        push %ecx
        movb fd, %cl
        push %ecx			#fd
        push $formatPrintfADD
        call printf
        add $24, %esp
        jmp et_ADD_exit
et_afisare_ADD:

        cmp dim, %eax
        jl et_spatiu_insuficient_ADD        #n am gasit destule poz cat are dim (ebx)

        mov %ecx, %ebx                  #ult poz nula
	mov %ecx, end
        sub dim, %ecx
        inc %ecx			#prima poz nula
	mov %ecx, start


	push %ebx
	call indexare
	pop %ebx

	push j
	push i				#pt printf

	push %ebx
	push %ecx
	call indexare
	pop %ecx
	pop %ebx

	push j
	push i				#pt printf

        xor %eax, %eax
        movb fd, %al
        push %eax                       #fd
        push $formatPrintfADD
        call printf
        add $24, %esp

	mov end, %ebx

	cmpb $1, defrag
	je et_modificare_sf_fis_precedent

        jmp et_adaugarea_ADD
et_modificare_sf_fis_precedent:
	mov %ebx, sf_fis_precedent
	jmp et_adaugarea_ADD
et_adaugarea_ADD:			#se ajunge aici doar daca am unde adauga, start are poz start, ebx are end, fd e v[i]
        inc %ebx			#ca sa iau toate valorile fara sa modific cmp desi puteam sa o fac
	xor %eax, %eax
	movb fd, %al
	mov $memorie, %esi		#posibil inutila
	mov start, %ecx
et_loop_adaugare_ADD:
        cmp %ebx, %ecx
        je et_ADD_exit

        movb %al, (%esi, %ecx, 1)        #v[i]
	xor %edx, %edx
	movb (%esi, %ecx, 1), %dl

        inc %ecx
        jmp et_loop_adaugare_ADD
et_ADD_exit:
	pop %ebp
        ret

GET:
    	push %ebp
        mov %esp, %ebp
        movb $0, verificare
	movb 8(%ebp), %al		#fd
	movb %al, fd
        xor %eax, %eax
        xor %ebx, %ebx
        xor %ecx, %ecx
        mov $memorie, %esi
et_loop_iterare_GET:
        cmp $1048576, %ecx			#DIMENSIUNEA
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

	push %eax			#pt salvare

	push %ebx
	call indexare
	add $4, %esp

	pop %eax

	push j
	push i				#end_i si end_j

	push %eax
	call indexare
	add $4, %esp
	push j
	push i				#start_i si start_j

        push $formatPrintfGET
        call printf
        add $20, %esp
        jmp et_GET_exit
et_GET_fara_afisare:			#pt defrag
	mov %eax, start			#indecsi intregi
	mov %ebx, end
	jmp et_GET_exit
et_GET_exit:
        pop %ebp
        ret

DELETE:
       	push %ebp
        mov %esp, %ebp
        movb 8(%ebp), %bl               #fd
        mov $memorie, %esi

        xor %ecx, %ecx
et_loop_stergere:
        cmp $1048576, %ecx                   #DIMENSIUNEA
        je et_DELETE_exit
					#xor %dl, %dl
        movb (%esi, %ecx, 1), %bh	#v[i]

	push %ecx			#sa nu l pierd

        cmpb %bl, %bh			#sterg valoarea ceruta
        je et_stergere

	cmpb $1, defrag			#evit afisarea la defrag
	je et_loop_stergere_continuare

	cmpb $0, %bh			#sar peste pozitiile goale
	je et_loop_stergere_continuare

	jmp et_afisare_DEL		#altfel afisez
et_loop_stergere_continuare:
	pop %ecx
        inc %ecx
        jmp et_loop_stergere
et_afisare_DEL:				#un else la cmp uri
	movb $1, defrag			#variabila impropriu folosita, nu vreau ca get sa afiseze

	movb %bh, fd

	push %ebx			#il salvez

	push fd
	call GET			#am start si end, indecsi intregi
	add $4, %esp

	push end
	call indexare
	add $4, %esp
	push j
	push i				#i si j pt end

	push start
	call indexare
	add $4, %esp
	push j
	push i				#i si j pt start

	push fd
	push $formatPrintfADD
	call printf
	add $24, %esp

	pop %ebx

	movb $0, defrag

	pop %ecx			#incrementez manual ca sa sar peste acelasi fisier de dim ori
	mov end, %eax
	sub start, %eax
	inc %eax
	add %eax, %ecx
	jmp et_loop_stergere
et_stergere:
	movb $0, (%esi, %ecx, 1)
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
        movb $1, defrag
	movl $0, start
	movl $0, end
	movl $0, sf_fis_precedent
        mov $memorie, %esi
et_iterare_DEF:
	cmp $1048576, %ecx                   #DIMENSIUNE
        je et_exit_DEF

        movb (%esi, %ecx, 1), %dl	#v[i]
        movb %dl, fd                    #nenecesar cred

        cmpb $0, %dl
        je et_inc_DEF
et_get_DEF:
        push %ecx                       #salvez indexarea vectorului

        push %edx
        call GET                        #apel functie in functie

        pop %edx
et_dim_DEF:
        mov end, %eax                           #am start si end
        sub start, %eax
        inc %eax
        mov %eax, dim                           #am dim in blocuri
et_delete_DEF:
        push %edx
        call DELETE
        pop %edx
et_add_DEF:
        mov dim, %eax
        push %eax
        push %edx
        call ADD
	pop %edx
        add $4, %esp

		#ma gandesc la un get aici, primul fisier adaugat oricum nu poate sa sara mai sus de sine
		#dupa fiecare fisier retin o pozitie ca sa stiu de unde am voie sa adaug urmatorul fisier
		#dupa ce am facut asta si pt ultimul, cum arata variabila si oare de asta da segfault?

	#sau sa folosesc end cumva, dar add trebuie sa mi dea valoarea end

        pop %ecx
        mov end, %ecx
et_inc_DEF:
	inc %ecx
        jmp et_iterare_DEF
et_exit_DEF:
	movb $0, defrag
        pop %ebp
        ret

#CONCRETE:
#	push %ebp
#	mov %esp, %ebp
					#	mov 8(%ebp), path		#variabila pt filepath
#	mov $5, %eax			#syscall open
#	mov $path, %ebx			#path
#	xor %ecx, %ecx			#flags read only
#	int $0x80

#	cmp $0, %eax			#open a avut succes
#	jl et_error

#	mov %eax, %edi			#fd al folderului

#	mov $141, %eax			#syscall getdents
#	mov %edi, %ebx			#fd folder
#	mov $buffer, %ecx		#buffer pt intrari
#	mov $1024, %edx			#dim buffer
#	int $0x80

#	cmp $0, %eax
#	je close_folder
#	jl et_error

#	mov %eax, N			#dim buffer ne spune cate elem sunt?
#	mov $buffer, %esi		#inceput de buffer

#	in baza buffer ului la poz 19 gasesc numele fisierului??????

#	mov $3, %ecx			#cum aflu N?
#	mov %ecx, N
#	xor %ecx, %ecx
#et_loop_conc:
#	cmp N, %ecx
#	je et_exit_conc

#	push %ecx			#il salvez

#	call concatenare		#facem path_fis prin cancatenare la path

#	call procesare_fisier		#push la ce?

#	movb $1, defrag
#	push fd
#	call GET			#get de fd ne zice daca exista deja, end = 0 sau nu DE FAPT NU INCA
#	pop %edx
#	movb %dl, fd
#	movb $0, defrag
#	mov end, %eax
#	cmp $0, %eax			#daca end==0 atunci adaugam fis nou
#	je et_putem_adauga

#et_inc_conc:
#	path ramane la fel????
#	pop %ecx
#	inc %ecx
#	jmp et_loop_conc
#et_putem_adauga:
#	movb $1, defrag			#nu vreau sa redimensioneze ce e corect, va face add cu afisare?
#	push dim
#	push fd
#	call ADD
#	add $8, %esp

#	jmp et_inc_conc
#et_error:
#	push $formatError2
#	call printf
#	add $4, %esp

#	jmp et_inc_conc
#et_exit_conc:
#	pop %ebp
#	ret

main:
        mov $memorie, %esi
et_citire_date:
	push $O
	push $formatScanf
	call scanf
	add $8, %esp			#O = nr de operatii de efectuat

	mov $0, %ecx			#de aici trebuie sa restaurez mereu ecx
et_loop_executare:
	cmp O, %ecx
	je et_exit

	push %ecx			#salvez counter

	push $cod_operatie
	push $formatScanf
	call scanf
	add $8, %esp

	cmpb $1, cod_operatie
	je et_add
	cmpb $2, cod_operatie
        je et_get
	cmpb $3, cod_operatie
        je et_del
	cmpb $4, cod_operatie
        je et_defrag
#	cmpb $5, cod_operatie
#	je et_concrete
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
et_loop_efectuare_ADD:
	cmp N, %ecx
	je et_inc

	push %ecx			#salvez counter

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

#et_concrete:
#	push $path
#	push $formatScanfConcrete
#	call scanf
#	add $8, %esp			#citesc path

#	push path
#	call CONCRETE
#	add $4, %esp

#	jmp et_inc

et_exit:
	pushl $0
	call fflush
	popl %eax

	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
