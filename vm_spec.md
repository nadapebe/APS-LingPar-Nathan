# LampVM - Especificação da Máquina Virtual

## Arquitetura

### Registradores
- **R0**: Registrador de propósito geral 0
- **R1**: Registrador de propósito geral 1

### Memória
- **Pilha**: Stack para operações aritméticas e controle de fluxo
- **Variáveis**: Memória para armazenar variáveis do programa (índices por nome)

### Sensores (Read-Only)
- **movimento**: Retorna 1 (true) se há movimento detectado, 0 (false) caso contrário
- **hora**: Retorna valor inteiro de 0 a 23 representando a hora atual

## Instruções Assembly

### Aritméticas
- `LOAD <valor>` - Carrega valor imediato ou de variável no R0
- `STORE <var>` - Armazena R0 na variável especificada
- `ADD <valor>` - Adiciona valor a R0 (R0 = R0 + valor)
- `SUB <valor>` - Subtrai valor de R0 (R0 = R0 - valor)
- `MUL <valor>` - Multiplica R0 por valor (R0 = R0 * valor)
- `DIV <valor>` - Divide R0 por valor (R0 = R0 / valor)

### Controle de Fluxo
- `JMP <label>` - Salta incondicionalmente para o label
- `JZ <label>` - Salta para o label se R0 == 0
- `JNZ <label>` - Salta para o label se R0 != 0
- `LABEL <nome>` - Define um label no código

### Pilha
- `PUSH` - Empilha R0 na pilha
- `POP` - Desempilha da pilha para R0

### Sensores e Ações
- `SENSOR movimento` - Carrega valor do sensor de movimento em R0
- `SENSOR hora` - Carrega valor do sensor de hora em R0
- `LAMP_ON` - Liga a lâmpada
- `LAMP_OFF` - Desliga a lâmpada

### Sistema
- `HALT` - Para a execução

## Exemplo de Código Assembly

```
LOAD 5
STORE N
LOAD 0
STORE semMov
LOAD 0
STORE ligada
LABEL loop_start
SENSOR hora
PUSH
LOAD 18
POP
SUB R0
JZ check_night
JMP check_night_alt
LABEL check_night
LOAD 1
JMP night_ok
LABEL check_night_alt
SENSOR hora
PUSH
LOAD 5
POP
SUB R0
JZ night_ok
LOAD 0
JMP night_check_end
LABEL night_ok
LOAD 1
LABEL night_check_end
PUSH
SENSOR movimento
POP
MUL R0
JZ else_block
...
HALT
```

## Turing-Completude

A VM é Turing-completa pois possui:
1. **Armazenamento**: Registradores e memória para variáveis
2. **Operações aritméticas**: ADD, SUB, MUL, DIV
3. **Controle de fluxo condicional**: JZ, JNZ (permite loops e condicionais)
4. **Salto incondicional**: JMP (permite loops infinitos)

Combinando JZ/JNZ com JMP, é possível implementar qualquer algoritmo computável.

