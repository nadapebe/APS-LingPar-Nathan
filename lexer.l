%option noyywrap

%{
#include "parser.tab.h"
#include <stdlib.h>
%}

DIGITO      [0-9]
LETRA       [A-Za-z]
ID          {LETRA}({LETRA}|{DIGITO}|_)*
NUM         {DIGITO}+

%%

"program"       { return PROGRAM; }
"var"           { return VAR; }
"int"           { return INT; }
"bool"          { return BOOL; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }

"lamp_on"       { return LAMP_ON; }
"lamp_off"      { return LAMP_OFF; }
"sensor"        { return SENSOR; }
"movimento"     { return MOVIMENTO; }
"hora"          { return HORA; }

"true"          { return TRUE; }
"false"         { return FALSE; }

"&&"            { return AND; }
"||"            { return OR; }
"=="            { return IGUAL; }
"<="            { return MENORIG; }
">="            { return MAIORIG; }
"<"             { return MENOR; }
">"             { return MAIOR; }
"+"             { return MAIS; }
"-"             { return MENOS; }
"*"             { return MULT; }
"/"             { return DIV; }
"!"             { return NOT; }
"="             { return ATRIB; }
":"             { return DOISPONTOS; }
"("             { return ABREPAR; }
")"             { return FECHAPAR; }
"{"             { return ABRECH; }
"}"             { return FECHACH; }
";"             { return PONTOVIRG; }

{NUM}           { yylval.num = atoi(yytext); return NUM; }
{ID}            { yylval.str = strdup(yytext); return ID; }
[ \t\r\n]+      ;
.               ;

%%