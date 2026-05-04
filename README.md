# Lab 6 – Instrucciones y Direccionamiento x86 (NASM)

**Arquitectura de Computadores · Unidad 6 · Post-Contenido 1**  
Universidad Francisco de Paula Santander · Ingeniería de Sistemas · 2026

---

## Descripción

Programa `.COM` de DOS ensamblado con NASM que demuestra las **cuatro categorías
fundamentales de instrucciones x86**:

| Bloque | Categoría            | Instrucciones usadas                     |
|--------|----------------------|------------------------------------------|
| 1      | Transferencia        | `MOV`, `LEA`, `XCHG`, `PUSH`, `POP`     |
| 2      | Aritmética           | `ADD`, `SUB`, `INC`, `DEC`, `MUL`, `DIV`|
| 3      | Lógica / Bits        | `AND`, `OR`, `XOR`, `TEST`, `SHL`, `SHR`|
| 4      | Control de flujo     | `CMP`, `JG`, `JE`, `JMP`, `LOOP`        |

---

## Estructura del Repositorio

```
apellido-post1-u6/
├── lab6_instrucciones.asm        ← Código fuente NASM
├── lab6_instrucciones.com        ← Binario compilado (formato .COM DOS)
├── README.md                     ← Este archivo
└── capturas/
    ├── checkpoint1_compilacion.png
    ├── checkpoint2a_debug_registros.png
    ├── checkpoint2b_add_ax57.png
    ├── checkpoint2c_sub_and_test_flags.png
    ├── checkpoint2d_bucle_ax15.png
    └── checkpoint3_factorial_120.png
```

---

## Requisitos

- **DOSBox 0.74+** — montaje de carpeta `MOUNT C ruta_local`
- **NASM 2.11+** para DOS (`nasm.exe` dentro del entorno DOSBox)
- **DEBUG.COM** — disponible en la imagen DOSBox o carpeta de herramientas

---

## Compilación y Ejecución

```dosbox
; Dentro de DOSBox:
MOUNT C C:\Users\usuario\apellido-post1-u6
C:
nasm -f bin lab6_instrucciones.asm -o lab6_instrucciones.com
lab6_instrucciones.com
```

---

## Descripción de cada Bloque

### Bloque 1 – Transferencia de Datos

Carga `valor_a = 45` y `valor_b = 12` desde memoria a registros.

| Instrucción | Operación | Resultado |
|-------------|-----------|-----------|
| `MOV ax,[valor_a]` | AX ← mem[valor_a] | AX = 45 |
| `MOV bx,[valor_b]` | BX ← mem[valor_b] | BX = 12 |
| `LEA si,[valor_a]` | SI ← dirección de valor_a | SI = offset |
| `MOV ax,[si]`      | AX ← mem[SI] (indirecto) | AX = 45 |
| `XCHG cx,dx`       | intercambio atómico CX↔DX | restaurado |
| `PUSH ax / POP ax` | pila preserva AX=45 | AX = 45 |

**Diferencia MOV vs LEA:** `MOV ax,[valor_a]` carga el **contenido** (45);
`LEA si,[valor_a]` carga la **dirección** (offset en el segmento).

---

### Bloque 2 – Operaciones Aritméticas

| Instrucción | Operación | Resultado | Flags afectados |
|-------------|-----------|-----------|-----------------|
| `ADD ax,[valor_b]` | 45+12 | AX=57 | ZF=0, CF=0, SF=0, OF=0 |
| `SUB ax,[valor_a]` | 12-45 | AX=-33 (0xFFDF) | SF=1, OF=0 |
| `INC ax` | 45+1 | AX=46 | ZF,SF,OF (no CF) |
| `DEC ax` | 46-1 | AX=45 | ZF,SF,OF (no CF) |
| `MUL bl` (AL=10,BL=7) | 10×7 | AX=70 | CF,OF según desbordamiento |
| `DIV bl` (AX=100,BL=7) | 100÷7 | AL=14, AH=2 | indefinido tras DIV |

> **Nota:** `INC`/`DEC` no modifican CF, lo que los hace útiles en
> bucles donde se preserva el carry de una operación anterior.

---

### Bloque 3 – Operaciones Lógicas

Valor inicial de ejemplo: `AL = 0xB7 = 1011 0111b`

| Instrucción | Operación bit a bit | Resultado | ZF |
|-------------|---------------------|-----------|----|
| `AND al,0Fh` | conserva 4 bits bajos | AL=07h | 0 |
| `OR al,0F0h` | activa 4 bits altos | AL=F7h | 0 |
| `XOR al,0FFh` | invierte todos los bits | AL=55h | 0 |
| `XOR bx,bx` | pone BX a cero | BX=0 | 1 |
| `TEST al,01h` | AND sin guardar (AL impar?) | AL=B7h | 0 (b0=1) |
| `SHL al,2` | AL×4 | AL=20h | depende |
| `SHR al,1` | AL÷2 | AL=10h | depende |

> **`XOR reg,reg`** es la forma estándar de poner a cero un registro en NASM:
> ocupa 2 bytes frente a los 3 bytes de `MOV reg,0`.

---

### Bloque 4 – Control de Flujo

#### Estructura if / else (CMP + saltos condicionales)

```
valor_a=45 > valor_b=12  →  JG .mayor  →  CX=1
```

| Instrucción | Condición | Flag evaluado |
|-------------|-----------|---------------|
| `JG  .mayor` | AX > mem (con signo) | SF==OF y ZF=0 |
| `JE  .igual` | AX == mem | ZF=1 |
| (sin salto) | AX < mem | SF≠OF |

#### Bucle LOOP (suma acumulada 1…5)

```
AX = 0+1+2+3+4+5 = 15   (CX decrementado desde 5 → 0)
```

| Iteración | BX (sumando) | AX (acum.) | CX |
|-----------|-------------|-------------|----|
| 1 | 1 | 1 | 4 |
| 2 | 2 | 3 | 3 |
| 3 | 3 | 6 | 2 |
| 4 | 4 | 10 | 1 |
| 5 | 5 | 15 | 0 |

---

## Tabla de Registros y Flags Observados (resumen DEBUG)

| Instrucción trazada | AX | BX | CX | ZF | CF | SF | OF |
|---------------------|----|----|----|----|----|----|----|
| `MOV ax,[valor_a]`  | 002D | 0000 | — | 0 | 0 | 0 | 0 |
| `MOV bx,[valor_b]`  | 002D | 000C | — | 0 | 0 | 0 | 0 |
| `ADD ax,[valor_b]`  | 0039 | 000C | — | 0 | 0 | 0 | 0 |
| `SUB ax,[valor_a]`  | FFDF | 000C | — | 0 | 1 | 1 | 0 |
| `AND al,[mascara]`  | 0007 | — | — | 0 | 0 | 0 | 0 |
| `TEST al,01h`       | 00B7 | — | — | 0 | 0 | 0 | 0 |
| `CMP ax,[valor_b]`  | 002D | — | — | 0 | 0 | 0 | 0 |
| `LOOP` (fin bucle)  | 000F | 0006 | 0000 | — | — | — | — |

---

## Checkpoint 3 – Variante Factorial

Para calcular **5! = 120** se reemplaza el bucle suma por:

```nasm
MOV ax, 1           ; AX = 1 (neutro multiplicativo)
MOV cx, 5           ; CX = 5
.bucle_factorial:
    MUL cx          ; AX = AX * CX
    DEC cx          ; CX--
    JNZ .bucle_factorial
; Resultado: AX = 120
```

| Iteración | CX | AX |
|-----------|----|----|
| 1 | 5 | 1×5 = 5 |
| 2 | 4 | 5×4 = 20 |
| 3 | 3 | 20×3 = 60 |
| 4 | 2 | 60×2 = 120 |
| 5 | 1 | 120×1 = 120 |

### LOOP vs DEC/JNZ

| Aspecto | `LOOP etiqueta` | `DEC reg` + `JNZ etiqueta` |
|---------|-----------------|---------------------------|
| Registro | **Siempre CX** | Cualquier registro |
| Instrucciones | 1 (compacta) | 2 (más verboso) |
| Flexibilidad | Baja (CX ocupado) | Alta (CX libre para otros usos) |
| Rendimiento | En CPUs modernas LOOP puede ser lento | DEC/JNZ igual o más rápido |
| Cuándo usarla | Bucles simples donde CX está libre | Cuando CX se usa en el cuerpo del bucle o se necesita otro registro |

**Conclusión:** `LOOP` es conveniente para bucles cortos y claros;
`DEC/JNZ` es preferible cuando el cuerpo del bucle ya usa `CX`
(por ejemplo en operaciones con `MUL`/`DIV` que usan `CX` implícitamente o si se anidan bucles).

---

## Capturas del Proceso

| Archivo | Contenido |
|---------|-----------|
| `checkpoint1_compilacion.png` | NASM sin errores, archivo `.com` generado |
| `checkpoint2a_debug_registros.png` | DEBUG: estado inicial de registros |
| `checkpoint2b_add_ax57.png` | DEBUG: AX=57 tras ADD, flags ZF=CF=0 |
| `checkpoint2c_sub_and_test_flags.png` | DEBUG: SF=1 tras SUB, ZF tras AND/TEST |
| `checkpoint2d_bucle_ax15.png` | DEBUG: AX=15 al terminar el bucle LOOP |
| `checkpoint3_factorial_120.png` | DEBUG: AX=120 con variante DEC/JNZ |

---

## Commits del Repositorio

```
feat: estructura base .COM y bloque transferencia (MOV, LEA, XCHG, PUSH/POP)
feat: agregar bloque aritmetico (ADD, SUB, INC, DEC, MUL, DIV)
feat: agregar bloque logico (AND, OR, XOR, TEST, SHL, SHR)
feat: agregar control de flujo (CMP, JG, JE, LOOP)
fix: corregir bucle factorial con DEC/JNZ y documentar diferencias
docs: README con tabla de registros, flags y capturas DEBUG
```
