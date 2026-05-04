; ============================================================
; lab6_instrucciones.asm
; Demostración de categorías de instrucciones x86 en NASM
; Autor   : [Tu Nombre]
; Materia : Arquitectura de Computadores - Unidad 6
; Compilar: nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com
; Ejecutar: lab6_instrucciones.com  (dentro de DOSBox)
; ============================================================

org 100h          ; offset de inicio para archivos .COM (PSP ocupa 0x00-0xFF)

; ── Datos ────────────────────────────────────────────────────
jmp inicio        ; saltar sobre los datos al código

valor_a   dw 45   ; primer operando
valor_b   dw 12   ; segundo operando
resultado dw 0    ; almacena resultado aritmético
contador  db 5    ; contador de bucle
mascara   db 0Fh  ; máscara de 4 bits bajos (0000 1111b)

; ── Código ───────────────────────────────────────────────────
inicio:

; ════════════════════════════════════════════════════════════
; BLOQUE 1: Transferencia de datos
;   Instrucciones: MOV, LEA, XCHG, PUSH, POP
; ════════════════════════════════════════════════════════════

    ; MOV: carga valor de memoria a registro
    MOV ax, [valor_a]   ; AX = 45  (contenido de valor_a)
    MOV bx, [valor_b]   ; BX = 12  (contenido de valor_b)

    ; MOV entre registros
    MOV cx, ax          ; CX = AX = 45
    MOV dx, bx          ; DX = BX = 12

    ; LEA: carga la dirección efectiva, NO el contenido
    LEA si, [valor_a]   ; SI = dirección de valor_a (offset en segmento)
    MOV ax, [si]        ; AX = mem[SI] = 45  (acceso indirecto vía SI)

    ; XCHG: intercambio atómico de dos registros
    XCHG cx, dx         ; CX=12, DX=45
    XCHG cx, dx         ; restaurar: CX=45, DX=12

    ; PUSH/POP: preservar y restaurar valor en la pila
    PUSH ax             ; guarda AX=45 en la pila (SP -= 2)
    MOV  ax, 0FFFFh     ; modifica AX temporalmente
    POP  ax             ; restaura AX=45  (SP += 2)

; ════════════════════════════════════════════════════════════
; BLOQUE 2: Operaciones aritméticas
;   Instrucciones: ADD, SUB, INC, DEC, MUL, DIV
;   Flags observados: ZF, CF, SF, OF
; ════════════════════════════════════════════════════════════

    ; ADD: suma con actualización de flags
    MOV ax, [valor_a]   ; AX = 45
    ADD ax, [valor_b]   ; AX = 45 + 12 = 57   (ZF=0, CF=0, SF=0, OF=0)
    MOV [resultado], ax ; guarda 57 en memoria

    ; SUB: resta — puede activar SF si el resultado es negativo
    MOV ax, [valor_b]   ; AX = 12
    SUB ax, [valor_a]   ; AX = 12 - 45 = -33  (SF=1, OF=0, resultado en complemento a 2)

    ; INC y DEC: incremento / decremento (NO afectan CF)
    MOV ax, [valor_a]   ; AX = 45
    INC ax              ; AX = 46
    DEC ax              ; AX = 45

    ; MUL: multiplicación sin signo  →  AX = AL * operando
    MOV al, 10          ; AL = 10
    MOV bl, 7           ; BL = 7
    MUL bl              ; AX = AL * BL = 70   (AH=0, resultado cabe en AL)

    ; DIV: división sin signo  →  AL = cociente, AH = resto
    MOV ax, 100         ; AX = 100
    MOV bl, 7           ; BL = 7
    DIV bl              ; AL = 14, AH = 2   (100 = 7*14 + 2)

; ════════════════════════════════════════════════════════════
; BLOQUE 3: Operaciones lógicas
;   Instrucciones: AND, OR, XOR, NOT, TEST, SHL, SHR
; ════════════════════════════════════════════════════════════

    MOV al, 0B7h        ; AL = 1011 0111b = 0xB7

    ; AND: máscara de limpieza — conserva solo los 4 bits bajos
    AND al, [mascara]   ; AL = 0B7h AND 0Fh = 0000 0111b = 07h
                        ; ZF=0 (resultado != 0)

    MOV al, 0B7h        ; restaurar AL = 0xB7

    ; OR: activar bits — activa los 4 bits altos
    OR  al, 0F0h        ; AL = 0B7h OR F0h = 1111 0111b = F7h

    MOV al, 0AAh        ; AL = 1010 1010b

    ; XOR: inversión selectiva de bits
    XOR al, 0FFh        ; AL = NOT AL = 0101 0101b = 55h

    ; XOR reg,reg: forma estándar de poner a cero un registro
    ; (codificación de 2 bytes vs 3 bytes de MOV reg,0)
    XOR bx, bx          ; BX = 0  (más eficiente que MOV bx,0)

    ; TEST: AND sin guardar resultado — solo actualiza flags
    MOV al, 0B7h
    TEST al, 01h        ; ZF=0 porque bit 0 de 0B7h = 1 (número impar)
                        ; AL sigue siendo 0B7h (TEST no modifica el operando)

    ; SHL / SHR: desplazamiento lógico = multiplicar / dividir por 2^n
    MOV al, 08h         ; AL = 8
    SHL al, 2           ; AL = 8 << 2 = 32 = 0x20  (CF = último bit saliente)
    SHR al, 1           ; AL = 32 >> 1 = 16 = 0x10

; ════════════════════════════════════════════════════════════
; BLOQUE 4: Control de flujo — Condicionales y Bucles
;   Instrucciones: CMP, JG, JE, JMP, LOOP
; ════════════════════════════════════════════════════════════

    ; Estructura if / else: comparar valor_a con valor_b
    MOV ax, [valor_a]   ; AX = 45
    CMP ax, [valor_b]   ; AX - valor_b = 45 - 12 = 33 > 0
                        ; SF=0, ZF=0, OF=0  →  JG tomará el salto
    JG  .mayor          ; salta si AX > valor_b (signed: SF == OF, ZF=0)
    JE  .igual          ; salta si AX == valor_b (ZF=1) — no se alcanza aquí
    ; caso menor (no se alcanza en este ejemplo)
    XOR cx, cx          ; CX = 0 como indicador "menor"
    JMP .fin_cmp

.mayor:
    MOV cx, 1           ; CX = 1: indica que valor_a > valor_b
    JMP .fin_cmp

.igual:
    MOV cx, 2           ; CX = 2: indica igualdad

.fin_cmp:

    ; ── Bucle: suma acumulada de 1 a 5 ──────────────────────
    ; Resultado esperado: 1+2+3+4+5 = 15
    XOR ax, ax          ; AX = 0  (acumulador, limpia sin usar MOV)
    MOV cx, 5           ; CX = contador del bucle (LOOP decrementa CX)
    MOV bx, 1           ; BX = valor inicial a sumar

.bucle_suma:
    ADD ax, bx          ; AX += BX
    INC bx              ; BX++ (avanza al siguiente sumando)
    LOOP .bucle_suma    ; DEC CX; si CX != 0 → .bucle_suma
    ; Al finalizar: AX = 15, CX = 0, BX = 6

    ; ── Fin del programa ─────────────────────────────────────
    INT 20h             ; interrupción DOS: retornar al sistema operativo

; ============================================================
; VARIANTE CHECKPOINT 3: Factorial de 5  (5! = 120)
; Descomentar estas líneas y comentar el bucle_suma anterior
; para probar la variante factorial con DEC/JNZ.
;
;   XOR dx, dx          ; DX = 0 (no usado, limpieza)
;   MOV ax, 1           ; AX = 1  (acumulador factorial, neutro multiplicativo)
;   MOV cx, 5           ; CX = 5  (contador: multiplica por 5,4,3,2,1)
;
; .bucle_factorial:
;   MUL cx              ; AX = AX * CX  (MUL usa AX implícitamente)
;   DEC cx              ; CX--
;   JNZ .bucle_factorial ; si CX != 0 → continuar
;   ; Al finalizar: AX = 120 = 5!
;   INT 20h
;
; DIFERENCIA LOOP vs DEC/JNZ:
;   LOOP  : decrementa CX y salta si CX != 0. Solo usa CX. 1 instrucción.
;           Limitación: siempre usa CX, menos flexible.
;   DEC/JNZ: decrementa cualquier registro y salta si ZF=0.
;           Más flexible (cualquier registro), útil cuando CX ya está en uso.
;           También permite condiciones de salida más complejas.
; ============================================================
