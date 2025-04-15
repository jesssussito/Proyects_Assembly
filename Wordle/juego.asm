;	PROGRAMA WORDLE DEBE ESTAR ACOMPAÑADO DE LOS ARCHIVOS main.asm diccionario.asm cadenas.asm
;JAVIER ALONSO MUÑOZ Y ALEJANDRO ACEVES BARBERO
	.module colores
.globl imprime_cadena
.globl juego
.globl Diccionario
.globl num_palabras
.globl carga_numero
.globl imprime_num
scan	.equ 0xff02
print	.equ 0xff00
descubre: 	.asciz "....."
palabra: 	.asciz "....."
intentos:	.asciz "                              ";30 caracteres (colores)
		.asciz "                              "
		.asciz "                              "
		.asciz "                              "
		.asciz "                              "
		.asciz "                              "
menu_palabras:	.ascii"\33[37m   | JUEGO |\n"
		.ascii"   -----------------\n"
    		.ascii"   | 12345 |\n"
		.ascii"   -----------------\n"
     			 .asciz"1  | "
     		.asciz"\33[37m\n2  | "
     		.asciz"\33[37m\n3  | "
     		.asciz"\33[37m\n4  | "
     		.asciz"\33[37m\n5  | "
     		.asciz"\33[37m\n6  | "
sin_intentos: .asciz "\33[31mTE HAS QUEDADO SIN INTENTOS LA PALABRA ERA: "
contador_intentos: .byte 0
contador_letras: .byte 0
siguiente_palabra_dir: .word 0x0000
pedir_palabra: .asciz "introduce el numero de palabra del 1 al "
rojo:   .ascii "\33[31m"
amarillo: .ascii "\33[33m"
verde:	.ascii "\33[32m"
reinicia: .asciz"\nSe reinica el juego\n"
no_esta: .asciz"Esa palabra no se encuentra en el diccionario\n"
ganado: .asciz "\33[32mENHORABUENA HAS ACERTADO LA PALABRA"
palabra_intento: .asciz "PALABRA: "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;juego:                                        ;
;contiene casi todo para hacer el wordle       ;
;                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
juego:
		pshs a,b
reinicio:
		ldy #intentos
		pshu y
set_palabra:
		lda #'\n
		sta print
		ldx #pedir_palabra
		jsr imprime_cadena
		lda num_palabras
		jsr imprime_num
		lda #':
		sta print
		lda #' 
		sta print
		
		jsr carga_numero ;cargar varios numeros
		cmpb num_palabras
		bgt set_palabra
		
		subb #1 ;para que sea la palabra seleccionada y no la siguiente
		lda #5
		mul
		ldy #descubre
		ldx #Diccionario
		leax d,x
		jsr carga_palabra ;mete la palabra en la variable descubre
		lda #'\n
		sta print
		jsr imprime_menu_palabras
palabras:
		ldx #palabra_intento
		jsr imprime_cadena
		ldx #palabra
		clrb
carga_letra:
		lda scan
		cmpa #'A
		blo opcion
		cmpa #'Z
		bgt opcion
		cmpb #5
		beq no_escribe
		incb
		sta ,x+
		bra carga_letra
opcion: ;sino esta entre A y Z se busca que no sean los caracteres especiales del juego
		cmpa #'\n
		beq termina_palabra
		cmpa #'r
		beq	reinicia_juego
		cmpa #'v
		beq juego_termina
		cmpa #32 ;CODIGO ASCII ESPACIO
		beq borra_letra
		;sino no son ninguno de los caracteres del juego se borra lo que se ha puesto
no_escribe:
		lda #8    
		sta print
		lda #' 		
		sta print
		lda #8 ;codigo ascii del retroceso
		sta print
		bra carga_letra
borra_letra: ;si pulsa el espacio
		cmpb #0
		beq no_borra
		lda #8
		sta print
		lda #8
		sta print
		lda #' 
		sta print
		lda #8
		sta print
		leax -1,x
		decb
		bra carga_letra
no_borra:	;si intenta borrar y no se ha escrito nada
		lda #8
		sta print
		bra carga_letra

termina_palabra:
		cmpb #5  ;comprueba que se han puesto las 5 letras de la palabra sino hace que vuelva a cargarla
		bne palabras
		jsr comprobar ;funcion comprobar si es la palabra, si esta en el diccionario y poner colores
		cmpa #1 ;de la funcion compara_pp devuelve en a un 1 si la palabra es la misma mirar final comparar
		beq juego_termina_bien
		lda contador_intentos
		inca
		cmpa #6 ;6 palabras y termina sin acertar
		beq juego_termina_nod
		sta contador_intentos
		bra palabras
reinicia_juego:
		ldx #reinicia
		jsr imprime_cadena
		jsr limpia
		lbra reinicio ;long branch sino no llega
juego_termina_bien: ;si ha ganadoo
		ldx #ganado
		jsr imprime_cadena
		bra juego_termina
juego_termina_nod: ;se acabaron los intentos
		ldx #sin_intentos
		jsr imprime_cadena
		ldx #descubre
		jsr imprime_cadena
juego_termina:
		lda #'\n
		sta print	
		jsr limpia ;limpia por si acaso vuelve
		puls a,b
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;carga_palabra                                      ;
;  carga una palabra de una direccion de memoria    ;
;    a la variable cargada en x lo mete en la de y  ;
;entrada: X,Y                                       ;
;registros afectados: X,Y,A,CC                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
carga_palabra:
		pshs a,b
		clrb
cp_bucle:
		lda ,x+
		sta ,y+
		incb
		cmpb #5
		bne cp_bucle

		puls a,b
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;comprobar_pp                                     ;
;comprueba que es la misma palabra o no           ;
;entrada: X,Y                                     ;
;salida: A(0 no esta y 1 si)                      ;
;registros afectados: X,Y,A,CC                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comprobar_pp:
		pshs b
		clrb
cpp_bucle:		
		cmpb #5 
		beq cpp_iguales
		incb
		lda ,x+
		cmpa ,y+
		beq cpp_bucle
		lda #0
		bra cpp_salir
cpp_iguales:
		lda #1
cpp_salir:		
		puls b
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;comprobar:                                     ;
;   comprobar si es la palabra,                 ;
;    si esta en el diccionario y poner colores  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
comprobar:
		
		ldy #Diccionario ;comrpobacion si esta en diccionario
		sty siguiente_palabra_dir
		clrb
bucle_cpp_diccionario: ;en comprobar pp no acaba al final de la palabra asi que hay que hacer que este al final
		ldy siguiente_palabra_dir
		leay 5,y
		sty siguiente_palabra_dir
		leay -5,y
		ldx #palabra 
		jsr comprobar_pp
		incb
		cmpa #1
		beq c_iguales
		cmpb num_palabras
		beq c_no_diccionario
		bra bucle_cpp_diccionario
c_no_diccionario:
		ldx #no_esta
		jsr imprime_cadena
c_iguales:
		jsr poner_color
		clra
		;mira si la palabra es la buena
		ldy #palabra
		ldx #descubre
		jsr	comprobar_pp ;mirar como terminar
c_terminar:
		jsr imprime_menu_palabras
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;imprime_menu_palabras               ;
;  imprime el menu con las palabras  ;
;   puestas con colores ya           ;
;registros afectados: CC             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
imprime_menu_palabras:
		pshs d,y,x
		lda #'\n
		sta print
		clrb
		ldx #menu_palabras 
		ldy #intentos 
		jsr imprime_cadena ;imprime x hasta el primer \0
imp_bucle:
		exg x,y ;lo cambia para imprimir las palabras en intentos
		jsr imprime_cadena
		incb
		cmpb #11 ;la suma de todo lo que hay que imprimir es 11
		bne imp_bucle
		sta print;metemos espacio estre esto y lo siguiente
		sta print			
		puls d,y,x
		rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;poner_color                                     ;
;  pone las letras en amarillo, blanco o verde  ;
;   y las guarda en variable intentos           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
poner_color:
		clrb
		ldx #palabra ;cargas la palabra a comprobar
ce_bucle:
		cmpb #5 ;5 letras de la palabra
		beq ce_terminar
		incb
		lda ,x+
		stb contador_letras ;guarda en contador para poder utilizar b
		clrb
		ldy #descubre

ce_bucle2:

		cmpb #5
		beq ce_no_esta
		incb
		cmpa ,y+
		beq ce_esta
		bra ce_bucle2
			
ce_esta:
		cmpb contador_letras ;lo compara para ver si es mayor menor o igual
		beq ce_verde		;si es el mismo entonmces la letra esta en la misma posicion y por tanto es verde
		bhi ce_amarillo    ;si es mayor mi palabra ya no puede ser verde
		blo ce_esta_menor  ;si es menor puede ser verde
		
ce_verde:
		pshs x,y
		ldx #verde
		jsr cargar_color
		puls x,y
		bra ce_esta_term

ce_amarillo:
		pshs x,y
		ldx #amarillo
		jsr cargar_color
		puls x,y
		bra ce_esta_term
ce_esta_menor: ;si es menor sigues comparando y si encuentra otra igual compara en ce_esta para< ver si se pone en verde
			cmpb #5
			beq ce_amarillo
			incb
			cmpa ,y+
			beq ce_esta
			bra ce_esta_menor	
ce_esta_term: ;cargar contador_letras para seguir con el bucle
		ldb contador_letras
		bra ce_bucle	
ce_no_esta: ;si no esta lo pone en rojo
		pshs x,y
		ldx #rojo
		jsr cargar_color
		puls x,y
		ldb contador_letras
		bra ce_bucle
ce_terminar:;al terminar la palabra se pone un fin de cadena
		pulu y
		lda #0
		sta ,y+
		pshu y
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;cargar_color                                       ;
;  mete en la variable que se metio en u            ;
;   al principio el color y la letra guardada en a  ;
;entrada: A,X                                       ;
;registros afectados: CC                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cargar_color:
		pulu y
		jsr carga_palabra
		sta ,y+
		pshu y
		rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;limpiar:                                    ;
;  para los reinicios hay que limpiar        ;
;   las variables que han sido almacenadas   ;
;registros afectados: todos                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
limpia:	
		clrb
		stb contador_intentos 
		stb contador_letras ;limpiar contador_letras	
		ldy #intentos
		
l_cambia:;pone espacios en la variable intentos 
		lda #' 
		clrb		
l_bucle:;va cambiando todas las palarbas por espacios
		sta ,y+
		incb
		cmpb #30
		bne l_bucle
		lda #0
		sta ,y+
		clrb
		ldb contador_intentos
		incb
		stb contador_intentos
		cmpb #6
		bne l_cambia
l_termina:
		clrb
		stb contador_intentos ;limpiar contador_intentos
		pulu y ;limpiamos la pila u
		rts		

