# Compilador e ferramentas
CC = gcc
LEX = flex
YACC = bison -d
CFLAGS = -Wall

# Nomes dos arquivos
TARGET = lumimov
VM_TARGET = vm
LEX_FILE = lexer.l
YACC_FILE = parser.y

# Regras
all: $(TARGET) $(VM_TARGET)

$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) parser.tab.c lex.yy.c -o $(TARGET)

$(VM_TARGET): vm.c
	$(CC) $(CFLAGS) vm.c -o $(VM_TARGET)

parser.tab.c parser.tab.h: $(YACC_FILE)
	$(YACC) $(YACC_FILE)

lex.yy.c: $(LEX_FILE)
	$(LEX) $(LEX_FILE)

clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h $(TARGET) $(VM_TARGET) *.asm

test: $(TARGET) $(VM_TARGET)
	@echo "Testando compilação do exemplo..."
	./$(TARGET) examples/exemplo1.lm examples/exemplo1.asm
	@echo "Executando na VM..."
	./$(VM_TARGET) examples/exemplo1.asm 1 18

.PHONY: all clean test
