;	PROGRAMA WORDLE DEBE ESTAR ACOMPAÑADO DE LOS ARCHIVOS juego.asm diccionario.asm main.asm
	.module cadenas
print	.equ 0xff00
scan	.equ 0xff02
		.globl imprime_cadena
		.globl imprime_diccionario
		.globl imprime_num
		.globl carga_numero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_cadena                                                   ;
;     saca por la pantalla la cadena acabada en '\0 apuntada por X ;
;                                                                  ;
;   Entrada: X-direcciOn de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X, CC.                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
imprime_cadena:
        pshs a
sgte:   lda ,x+
        beq ret_imprime_cadena
        sta print
        bra sgte
ret_imprime_cadena:
        puls a
        rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; imprime_cadena                                                   ;
;     saca por la pantalla la cadena acabada en '\0 apuntada por X ;
;      poniendo \n cada 5 letras                                   ;
;   Entrada: X-direcciOn de comienzo de la cadena                  ;
;   Salida:  ninguna                                               ;
;   Registros afectados: X, CC.                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprime_diccionario:
        pshs a,b
		clrb
d_sgte:
	addb #1
	lda ,x+
        beq ret_diccionario
        sta print
        cmpb #5
        beq salto
        bra d_sgte
salto:
	ldb	#'\n
	stb print
	clrb
	bra d_sgte
ret_diccionario:

        puls a,b
        rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;imprime_num                                      ;
;   imprime numeros del 0 al 255                  ;
;  entrada A (un numero del 0 al 255)             ;
;  salida: ninguna(por pantalla)                  ;
;  registros: A CC                                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
variable: .byte 0
imprime_num:
	pshs b,x
	ldb #'0
        cmpa #100
        blo Menor100
        suba #100
        incb
        cmpa #100
        blo Menor200
        incb
        suba #100
Menor100:
Menor200:
	cmpb #'0
	beq no_cero
        stb print
no_cero:
        ; segunda cifra.  En A quedan las dos Ultimas cifras
        ldb #80
        stb variable
        clrb

bucle:  lslb
        cmpa variable
        blo Menor
        incb
        suba variable
Menor:  tfr d,x
        lda variable
        lsra
        sta variable
        cmpa #10
        tfr x,d
        bhs bucle

        addb #'0
        stb print
        adda #'0
        sta print
        
        puls b,x
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;carga_numero:                          ;
;  carga un numero del 0 al 99          ;
; entrada:scan                          ;
; salida: B                             ;
; registros afectados: B, CC            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
numero: .byte 0
carga_numero:
	pshs a
carga_numero1: ;no se escribe en pantalla sino es un numero
	lda scan
	cmpa #'0
	blo borra
	cmpa #'9
	bgt borra
	suba #'0
	ldb #10
	mul
carga_numero2:
	lda scan
	cmpa #'0
	blo borra2
	cmpa #'9
	bgt borra2
	suba #'0
	sta numero
	addb numero
	puls a
		rts
borra:
	lda #8    
	sta print
	lda #' 		
	sta print
	lda #8 ;codigo ascii del retroceso
	sta print
	bra carga_numero1
borra2:
	lda #8    
	sta print
	lda #' 		
	sta print
	lda #8 ;codigo ascii del retroceso
	sta print
	bra carga_numero2
