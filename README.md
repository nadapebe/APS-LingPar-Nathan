# APS LingPar Nathan

# LumiMov – Linguagem de Programação para Controle de Lâmpadas

## Sobre o Projeto

Este projeto implementa uma linguagem de programação de alto nível chamada **LumiMov** para controlar lâmpadas através de uma máquina virtual (LampVM). A linguagem foi desenvolvida usando **Flex** (análise léxica) e **Bison** (análise sintática), gerando código Assembly que é executado em uma VM customizada.

## Estrutura do Projeto

- `lexer.l` - Especificação do analisador léxico (Flex)
- `parser.y` - Especificação do analisador sintático e gerador de código (Bison)
- `vm.c` - Interpretador/emulador da LampVM
- `Makefile` - Script de compilação
- `examples/` - Exemplos de programas em LumiMov
- `vm_spec.md` - Especificação detalhada da LampVM

## Como Compilar e Usar

### Compilação

```bash
make clean
make
```

Isso irá gerar:
- `lumimov` - Compilador LumiMov
- `vm` - Interpretador da LampVM

### Compilando um Programa

```bash
./lumimov <arquivo_entrada.lm> [arquivo_saida.asm]
```

Exemplo:
```bash
./lumimov examples/exemplo1.lm examples/exemplo1.asm
```

### Executando na VM

```bash
./vm <arquivo.asm> [movimento] [hora]
```

Parâmetros:
- `movimento`: 0 (sem movimento) ou 1 (com movimento)
- `hora`: valor de 0 a 23

Exemplo:
```bash
./vm examples/exemplo1.asm 1 18
```

## LampVM - Máquina Virtual

A LampVM possui:
- **2 Registradores**: R0 (principal), R1 (auxiliar)
- **Memória**: Variáveis e pilha
- **Sensores**: movimento (bool), hora (int 0-23)
- **Instruções**: LOAD, STORE, ADD, SUB, MUL, DIV, PUSH, POP, JMP, JZ, JNZ, SENSOR, LAMP_ON, LAMP_OFF, HALT

A VM é Turing-completa, permitindo implementar qualquer algoritmo computável.

# LumiMov – Especificação em EBNF

## Objetivo
**LumiMov** é uma linguagem de alto nível para controlar uma **lâmpada** em uma VM simples com **sensores de movimento e hora**.  
Permite automações como “ligar à noite ao detectar movimento e apagar após N segundos sem movimento”, com **variáveis**, **condicionais** e **loops**.

## Especificação da Linguagem em EBNF
```ebnf
Programa        = "program" Identificador "{" { DeclVar | Comando } "}" ;

DeclVar         = "var" Identificador ":" Tipo [ "=" Expr ] ";" ;
Tipo            = "int" | "bool" ;

Comando         = Atrib ";" | If | While | Acao ";" ;
Atrib           = Identificador "=" Expr ;

If              = "if" "(" ExprBool ")" Block [ "else" Block ] ;
While           = "while" "(" ExprBool ")" Block ;
Block           = "{" { Comando } "}" ;

Acao            = "lamp_on" "(" ")" | "lamp_off" "(" ")" ;

Expr            = Soma ;
ExprBool        = Rel { ("&&" | "||") Rel } ;
Rel             = Soma [ ( "==" | "<" | "<=" | ">" | ">=" ) Soma ] ;
Soma            = Termo { ( "+" | "-" ) Termo } ;
Termo           = Fator { ( "*" | "/" ) Fator } ;

Fator           = Literal
                | Identificador
                | LeituraSensor
                | "(" Expr ")"
                | "!" Fator
                | "-" Fator ;

LeituraSensor   = "sensor" "(" NomeSensor ")" ;
NomeSensor      = "movimento" | "hora" ;

Literal         = Int | Bool ;
Int             = Digito { Digito } ;
Bool            = "true" | "false" ;

Identificador   = Letra { Letra | Digito | "_" } ;
Digito          = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
Letra           = "A" | ... | "Z" | "a" | ... | "z" ;
```
## Características da Linguagem

- Variáveis: int, bool, com atribuição e inicialização opcional.

- Condicionais: if/else com &&, ||, ! e comparações.

- Loops: while (cond) { ... }.

- Ações: lamp_on() e lamp_off().

- Sensores (nao pode altrerar o valor): sensor(movimento) → bool; sensor(hora) → int (0...23).

## Exemplo de Programa
```
program LampadaPresenca {

  var N : int = 15 ;
  var semMov : int = 0 ;
  var ligada : bool = false ;

  while (true) {
    if ( (sensor(hora) >= 18 || sensor(hora) <= 5) && sensor(movimento) ) {
      if (!ligada) {
        lamp_on();
        ligada = true;
        semMov = 0;
      }
    } else {
      if (ligada && !sensor(movimento)) {
        semMov = semMov + 1;
        if (semMov >= N) {
          lamp_off();
          ligada = false;
          semMov = 0;
        }
      } else {
        semMov = 0;
      }
    }
  }
}
```
Descrição do Exemplo:

1- N define quantos “ticks/segundos” sem movimento são necessários para apagar.

2- O laço principal roda continuamente.

3- Se for noite (hora >= 18 ou hora <= 5) e houver movimento, a lâmpada liga e o contador semMov zera.

4- Caso contrário:

- Se a lâmpada estiver ligada e não houver movimento, o contador semMov incrementa.

- Ao atingir N, a lâmpada desliga e o contador zera.

- Se voltar a haver movimento, o contador zera novamente.
