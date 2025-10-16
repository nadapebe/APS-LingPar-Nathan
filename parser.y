%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
%}

%token PROGRAM VAR INT BOOL IF ELSE WHILE
%token LAMP_ON LAMP_OFF SENSOR MOVIMENTO HORA
%token TRUE FALSE
%token AND OR IGUAL MENORIG MAIORIG MENOR MAIOR
%token MAIS MENOS MULT DIV NOT ATRIB DOISPONTOS
%token ABREPAR FECHAPAR ABRECH FECHACH PONTOVIRG
%token NUM ID

%left OR
%left AND
%left IGUAL MENOR MENORIG MAIOR MAIORIG
%left MAIS MENOS
%left MULT DIV
%right NOT UMINUS

%start programa

%%

programa:
    PROGRAM ID ABRECH declaracoes FECHACH
    ;

declaracoes:
    /* vazio */
    | declaracoes declaracao
    ;

declaracao:
    decl_var
    | comando
    ;

decl_var:
    VAR ID DOISPONTOS tipo PONTOVIRG
    | VAR ID DOISPONTOS tipo ATRIB expr PONTOVIRG
    ;

tipo:
    INT
    | BOOL
    ;

comando:
    atrib PONTOVIRG
    | if_stmt
    | while_stmt
    | acao PONTOVIRG
    ;

atrib:
    ID ATRIB expr
    ;

if_stmt:
    IF ABREPAR expr_bool FECHAPAR block
    | IF ABREPAR expr_bool FECHAPAR block ELSE block
    ;

while_stmt:
    WHILE ABREPAR expr_bool FECHAPAR block
    ;

block:
    ABRECH comandos FECHACH
    ;

comandos:
    /* vazio */
    | comandos comando
    ;

acao:
    LAMP_ON ABREPAR FECHAPAR
    | LAMP_OFF ABREPAR FECHAPAR
    ;

expr:
    soma
    ;

expr_bool:
    rel
    | expr_bool OR rel
    | expr_bool AND rel
    ;

rel:
    soma
    | rel IGUAL soma
    | rel MENOR soma
    | rel MENORIG soma
    | rel MAIOR soma
    | rel MAIORIG soma
    ;

soma:
    termo
    | soma MAIS termo
    | soma MENOS termo
    ;

termo:
    fator
    | termo MULT fator
    | termo DIV fator
    ;

fator:
    literal
    | ID
    | leitura_sensor
    | ABREPAR expr FECHAPAR
    | NOT fator
    | MENOS fator %prec UMINUS
    ;

leitura_sensor:
    SENSOR ABREPAR nome_sensor FECHAPAR
    ;

nome_sensor:
    MOVIMENTO
    | HORA
    ;

literal:
    NUM
    | TRUE
    | FALSE
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

int main(void) {
    printf(" Iniciando análise do programa LumiMov...\n");
    yyparse();
    printf(" Análise concluída com sucesso.\n");
    return 0;
}