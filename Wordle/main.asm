;	PROGRAMA WORDLE DEBE ESTAR ACOMPAÑADO DE LOS ARCHIVOS juego.asm diccionario.asm cadenas.asm
;JAVIER ALONSO MUÑOZ Y ALEJANDRO ACEVES BARBERO

print	.equ 0xff00
scan	.equ 0xff02
        .globl Diccionario
        .globl juego
		.globl imprime_cadena
		.globl imprime_diccionario
		.globl imprime_num
		.globl num_palabras
wordle:	.ascii "\33[1m\33[31mW     W  \33[32mOOOOO  RRRRR    \33[37mDDDDD   L       \33[33mEEEEE\n"  
	.ascii "\33[1m\33[31mW  W  W  \33[32mO   O  R    R   \33[37mD    D  L       \33[33mE\n" 
	.ascii "\33[1m\33[31mW W W W  \33[32mO   O  RRRRR    \33[37mD    D  L       \33[33mEEEEE\n"
	.ascii "\33[1m\33[31mWW   WW  \33[32mO   O  R    R   \33[37mD    D  L       \33[33mE\n" 
	.ascii "\33[1m\33[31mW     W  \33[32mOOOOO  R     R  \33[37mDDDDD   LLLLLL  \33[33mEEEEE\n\0"
controles:
	.ascii "El juego WORDLE consiste en adivinar una palabra en seis intentos.\n"
	.ascii "Las unicas pistas que tienes para adivinar la palabra"
	.ascii " son cuales de las letras que has puesto estan dentro de la palabra.\n"
	.ascii "En esta version del juego, si la letra esta en la posicion correcta, esta aparecera de "
	.ascii "color verde,\n por el contrario si la letra esta en la palabra pero su posicion no es la correcta"
	.ascii " la letra sera de color amarillo. \nPor ultimo si la letra no pertenece a la palabra esta sera de color blanco\n."
	.ascii "CONTROLES:\n"
	.ascii "Al empezar se tiene que escibir el numero si es menor de 10 de la formma 02\n"
	.ascii "Escribe la palabra que deseas probar con el teclado.\n"
	.ascii "Las letras introducidas DEBEN de estar en MAYUSCULAS.\n"
	.ascii "Pulsa ENTER para comprobar las letras de esa palabra.\n"
	.ascii "Si deseas borrar una letra pulsa la tecla ESPACIO.\n\n\0"
menu:   .ascii"\33[37m1)instrucciones\n"
	.ascii "2)mostrar el diccionario\n"
	.ascii "3)jugar al juego\n"
	.ascii "s)salir\n\0"
noAcierto: .asciz "no hay ninguna opcion con esa tecla"
hay: .asciz"PALABRAS: "
	 
clearScreen:.asciz "\33[2J"

programa:
		lds #0xff00
		ldu #0xf000
		ldx #wordle
		jsr imprime_cadena
		ldx #Diccionario
		jsr num_palabras_cont
ld_menu:

		ldx #menu
		jsr imprime_cadena
		lda scan
		ldb #'\n
		stb print
		cmpa #'1
		beq instrucciones
		cmpa #'2
		beq diccionario
		cmpa #'3
		beq jugar
		cmpa #'s
		beq acabar
		cmpa #'S
		beq acabar
		ldx #noAcierto
		jsr imprime_cadena
		lda #'\n
		sta print
		bra ld_menu
		
diccionario:
		ldx #Diccionario
		jsr imprime_diccionario
		ldx #hay
		jsr imprime_cadena
		lda num_palabras
		jsr imprime_num
		lda #'\n
		sta print
		bra ld_menu
jugar:
		jsr clear
		jsr juego
		lda #'\n
		sta print
		bra ld_menu
instrucciones:
		ldx #controles
		jsr imprime_cadena 
		BRA ld_menu
acabar:
		lda #'\n
		sta print
		clra
		sta 0xff01
clear:	
		pshu a,x
		ldx #clearScreen
		jsr imprime_cadena
		pulu a,x
		rts	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;num_palabras_cont
;cuenta las palabras que hay en el diccionario
;entrada : X con la direccion del diccionario
;salida: la variable num_palabras
;registros afectados X,CC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
num_palabras: .byte 0
num_palabras_cont:
        	pshs a,b
		clrb
n_sgte:
		incb
		lda ,x+
       		beq n_ret
		cmpb #5
		beq n_cont
		bra n_sgte
n_cont:
		;aumenta la variable de num_palabras contar palabras
		ldb num_palabras
		incb
		stb num_palabras
		clrb
		bra n_sgte
n_ret:
		puls a,b
		rts

		.area fija(ABS)
		.org 0xfffe
		.word programa

