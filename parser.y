%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#define MAX_VARS 100

typedef struct {
    char name[64];
    int index;
} Variable;

FILE *output_file;
Variable variables[MAX_VARS];
int var_count = 0;
int label_counter = 0;

int find_var(const char *name);
int add_var(const char *name);
char* new_label(void);
void emit(const char *fmt, ...);
void safe_free(char *ptr);

void yyerror(const char *s);
int yylex(void);
extern char *yytext;
extern FILE *yyin;
%}

%union {
    int num;
    char *str;
}

%token <num> NUM
%token <str> ID
%token PROGRAM VAR INT BOOL IF ELSE WHILE
%token LAMP_ON LAMP_OFF SENSOR MOVIMENTO HORA
%token TRUE FALSE
%token AND OR IGUAL MENORIG MAIORIG MENOR MAIOR
%token MAIS MENOS MULT DIV NOT ATRIB DOISPONTOS
%token ABREPAR FECHAPAR ABRECH FECHACH PONTOVIRG

%left OR
%left AND
%left IGUAL MENOR MENORIG MAIOR MAIORIG
%left MAIS MENOS
%left MULT DIV
%right NOT UMINUS

%type <str> programa declaracoes declaracao decl_var tipo comando atrib if_stmt while_stmt block comandos acao
%type <str> expr expr_bool rel soma termo fator leitura_sensor nome_sensor literal

%start programa

%%

programa:
    PROGRAM ID ABRECH declaracoes FECHACH {
        emit("HALT");
        fclose(output_file);
        printf("Código Assembly gerado com sucesso!\n");
    }
    ;

declaracoes:
    /* vazio */ { $$ = NULL; }
    | declaracoes declaracao { safe_free($1); safe_free($2); $$ = NULL; }
    ;

declaracao:
    decl_var
    | comando
    ;

decl_var:
    VAR ID DOISPONTOS tipo PONTOVIRG {
        add_var($2);
        emit("LOAD 0");
        emit("STORE %s", $2);
        safe_free($2);
        $$ = NULL;
    }
    | VAR ID DOISPONTOS tipo ATRIB expr PONTOVIRG {
        add_var($2);
        emit("STORE %s", $2);
        safe_free($2);
        safe_free($6);
        $$ = NULL;
    }
    ;

tipo:
    INT { $$ = NULL; }
    | BOOL { $$ = NULL; }
    ;

comando:
    atrib PONTOVIRG {
        safe_free($1);
    }
    | if_stmt {
        safe_free($1);
    }
    | while_stmt {
        safe_free($1);
    }
    | acao PONTOVIRG {
        safe_free($1);
    }
    ;

atrib:
    ID ATRIB expr {
        int idx = find_var($1);
        if (idx == -1) {
            yyerror("Variável não declarada");
            YYERROR;
        }
        emit("STORE %s", $1);
        $$ = strdup($1);
        safe_free($1);
    }
    ;

if_stmt:
    IF ABREPAR expr_bool FECHAPAR block {
        char *else_label = new_label();
        char *end_label = new_label();
        emit("JZ %s", else_label);
        safe_free($3);
        safe_free($5);
        emit("LABEL %s", else_label);
        emit("LABEL %s", end_label);
        free(else_label);
        free(end_label);
        $$ = strdup(end_label);
    }
    | IF ABREPAR expr_bool FECHAPAR block ELSE block {
        char *else_label = new_label();
        char *end_label = new_label();
        emit("JZ %s", else_label);
        safe_free($3);
        safe_free($5);
        emit("JMP %s", end_label);
        emit("LABEL %s", else_label);
        safe_free($7);
        emit("LABEL %s", end_label);
        free(else_label);
        free(end_label);
        $$ = strdup(end_label);
    }
    ;

while_stmt:
    WHILE ABREPAR expr_bool FECHAPAR block {
        char *loop_start = new_label();
        char *loop_end = new_label();
        emit("LABEL %s", loop_start);
        safe_free($3);
        emit("JZ %s", loop_end);
        safe_free($5);
        emit("JMP %s", loop_start);
        emit("LABEL %s", loop_end);
        free(loop_start);
        free(loop_end);
        $$ = strdup(loop_end);
    }
    ;

block:
    ABRECH comandos FECHACH {
        $$ = $2;
    }
    ;

comandos:
    /* vazio */ {
        $$ = NULL;
    }
    | comandos comando {
        safe_free($1);
        $$ = $2;
    }
    ;

acao:
    LAMP_ON ABREPAR FECHAPAR {
        emit("LAMP_ON");
        $$ = strdup("lamp_on");
    }
    | LAMP_OFF ABREPAR FECHAPAR {
        emit("LAMP_OFF");
        $$ = strdup("lamp_off");
    }
    ;

expr:
    soma {
        $$ = $1;
    }
    ;

expr_bool:
    rel {
        $$ = $1;
    }
    | expr_bool OR rel {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("JNZ %s", true_label);
        safe_free($1);
        emit("JNZ %s", true_label);
        safe_free($3);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | expr_bool AND rel {
        char *false_label = new_label();
        char *end_label = new_label();
        emit("JZ %s", false_label);
        safe_free($1);
        emit("JZ %s", false_label);
        safe_free($3);
        emit("LOAD 1");
        emit("JMP %s", end_label);
        emit("LABEL %s", false_label);
        emit("LOAD 0");
        emit("LABEL %s", end_label);
        free(false_label);
        $$ = strdup(end_label);
    }
    ;

rel:
    soma {
        $$ = $1;
    }
    | rel IGUAL soma {
        char *true_label = new_label();
        char *end_label = new_label();
        safe_free($1);
        emit("PUSH");
        safe_free($3);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        emit("JZ %s", true_label);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | rel MENOR soma {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("PUSH");
        safe_free($1);
        safe_free($3);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        emit("JZ %s", end_label);
        emit("LOAD 1");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 0");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | rel MENORIG soma {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("PUSH");
        safe_free($1);
        safe_free($3);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        emit("JZ %s", true_label);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | rel MAIOR soma {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("PUSH");
        safe_free($1);
        safe_free($3);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        emit("JZ %s", end_label);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | rel MAIORIG soma {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("PUSH");
        safe_free($1);
        safe_free($3);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        emit("JZ %s", true_label);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    ;

soma:
    termo {
        $$ = $1;
    }
    | soma MAIS termo {
        emit("PUSH");
        emit("STORE_R1");
        emit("POP");
        emit("ADD R1");
        safe_free($1);
        safe_free($3);
        $$ = strdup("add");
    }
    | soma MENOS termo {
        emit("PUSH");
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        safe_free($1);
        safe_free($3);
        $$ = strdup("sub");
    }
    ;

termo:
    fator {
        $$ = $1;
    }
    | termo MULT fator {
        emit("PUSH");
        emit("STORE_R1");
        emit("POP");
        emit("MUL R1");
        safe_free($1);
        safe_free($3);
        $$ = strdup("mult");
    }
    | termo DIV fator {
        emit("PUSH");
        emit("STORE_R1");
        emit("POP");
        emit("DIV R1");
        safe_free($1);
        safe_free($3);
        $$ = strdup("div");
    }
    ;

fator:
    literal {
        $$ = $1;
    }
    | ID {
        int idx = find_var($1);
        if (idx == -1) {
            yyerror("Variável não declarada");
            YYERROR;
        }
        emit("LOAD %s", $1);
        $$ = strdup($1);
        safe_free($1);
    }
    | leitura_sensor {
        $$ = $1;
    }
    | ABREPAR expr FECHAPAR {
        $$ = $2;
    }
    | NOT fator {
        char *true_label = new_label();
        char *end_label = new_label();
        emit("JZ %s", true_label);
        emit("LOAD 0");
        emit("JMP %s", end_label);
        emit("LABEL %s", true_label);
        emit("LOAD 1");
        emit("LABEL %s", end_label);
        safe_free($2);
        safe_free(true_label);
        $$ = strdup(end_label);
    }
    | MENOS fator %prec UMINUS {
        emit("LOAD 0");
        emit("PUSH");
        safe_free($2);
        emit("STORE_R1");
        emit("POP");
        emit("SUB R1");
        $$ = strdup("uminus");
    }
    ;

leitura_sensor:
    SENSOR ABREPAR nome_sensor FECHAPAR {
        if (strcmp($3, "movimento") == 0) {
            emit("SENSOR movimento");
        } else if (strcmp($3, "hora") == 0) {
            emit("SENSOR hora");
        }
        safe_free($3);
        $$ = strdup("sensor");
    }
    ;

nome_sensor:
    MOVIMENTO {
        $$ = strdup("movimento");
    }
    | HORA {
        $$ = strdup("hora");
    }
    ;

literal:
    NUM {
        emit("LOAD %d", $1);
        $$ = strdup("num");
    }
    | TRUE {
        emit("LOAD 1");
        $$ = strdup("true");
    }
    | FALSE {
        emit("LOAD 0");
        $$ = strdup("false");
    }
    ;

%%

int find_var(const char *name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(variables[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int add_var(const char *name) {
    if (find_var(name) != -1) {
        return find_var(name);
    }
    strcpy(variables[var_count].name, name);
    variables[var_count].index = var_count;
    return var_count++;
}

char* new_label(void) {
    char *label = malloc(32);
    sprintf(label, "L%d", label_counter++);
    return label;
}

void emit(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vfprintf(output_file, fmt, args);
    fprintf(output_file, "\n");
    va_end(args);
}

void safe_free(char *ptr) {
    if (ptr != NULL) {
        free(ptr);
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe: %s\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo_entrada> [arquivo_saida]\n", argv[0]);
        return 1;
    }
    
    FILE *input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Erro ao abrir arquivo de entrada: %s\n", argv[1]);
        return 1;
    }
    
    char output_name[256];
    if (argc >= 3) {
        strcpy(output_name, argv[2]);
    } else {
        strcpy(output_name, argv[1]);
        char *dot = strrchr(output_name, '.');
        if (dot) *dot = '\0';
        strcat(output_name, ".asm");
    }
    
    output_file = fopen(output_name, "w");
    if (!output_file) {
        fprintf(stderr, "Erro ao criar arquivo de saída: %s\n", output_name);
        fclose(input);
        return 1;
    }
    
    yyin = input;
    printf("Compilando programa LumiMov...\n");
    yyparse();
    printf("Compilação concluída. Assembly gerado em: %s\n", output_name);
    
    fclose(input);
    return 0;
}
