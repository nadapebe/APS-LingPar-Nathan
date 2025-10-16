# Compilador e ferramentas
CC = gcc
LEX = flex
YACC = bison -d
CFLAGS = -Wall

# Nomes dos arquivos
TARGET = lumimov
LEX_FILE = lexer.l
YACC_FILE = parser.y

# Regras
all: $(TARGET)

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) parser.tab.c lex.yy.c -o $(TARGET)

parser.tab.c parser.tab.h: $(YACC_FILE)
	$(YACC) $(YACC_FILE)

lex.yy.c: $(LEX_FILE)
	$(LEX) $(LEX_FILE)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h $(TARGET)

.PHONY: all clean
