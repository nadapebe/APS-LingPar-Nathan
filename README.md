# APS LingPar Nathan

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
