# APS-LingPar-Nathan

# Lumi – Especificação em EBNF

## Objetivo
**Lumi** é uma linguagem de alto nível para controlar uma **lâmpada** em uma VM simples com **sensores de movimento e hora**.  
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

Características da Linguagem

Variáveis: int, bool, com atribuição e inicialização opcional.

Condicionais: if/else com &&, ||, ! e comparações.

Loops: while (cond) { ... }.

Ações: lamp_on() e lamp_off().

Sensores (read-only): sensor(movimento) → bool; sensor(hora) → int (0..23).
