#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_STACK 1000
#define MAX_MEM 1000
#define MAX_LABELS 1000
#define MAX_LINE 256

typedef struct {
    char name[64];
    int value;
} Variable;

typedef struct {
    char name[64];
    int addr;
} Label;

int R0 = 0, R1 = 0;
int stack[MAX_STACK];
int sp = 0;
Variable memory[MAX_MEM];
int mem_count = 0;
Label labels[MAX_LABELS];
int label_count = 0;

int movimento_sensor = 0;
int hora_sensor = 12;
int lamp_state = 0;

int find_var(const char *name) {
    for (int i = 0; i < mem_count; i++) {
        if (strcmp(memory[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int get_var(const char *name) {
    int idx = find_var(name);
    if (idx == -1) {
        idx = mem_count++;
        strcpy(memory[idx].name, name);
        memory[idx].value = 0;
    }
    return memory[idx].value;
}

void set_var(const char *name, int value) {
    int idx = find_var(name);
    if (idx == -1) {
        idx = mem_count++;
        strcpy(memory[idx].name, name);
    }
    memory[idx].value = value;
}

void push(int value) {
    if (sp >= MAX_STACK) {
        fprintf(stderr, "Erro: Stack overflow\n");
        exit(1);
    }
    stack[sp++] = value;
}

int pop(void) {
    if (sp <= 0) {
        fprintf(stderr, "Erro: Stack underflow\n");
        exit(1);
    }
    return stack[--sp];
}

int find_label(const char *name) {
    for (int i = 0; i < label_count; i++) {
        if (strcmp(labels[i].name, name) == 0) {
            return labels[i].addr;
        }
    }
    return -1;
}

void add_label(const char *name, int addr) {
    int idx = find_label(name);
    if (idx == -1) {
        strcpy(labels[label_count].name, name);
        labels[label_count].addr = addr;
        label_count++;
    } else {
        labels[idx].addr = addr;
    }
}

int parse_value(const char *str, int *value) {
    if (isdigit(str[0]) || (str[0] == '-' && isdigit(str[1]))) {
        *value = atoi(str);
        return 1;
    }
    if (strcmp(str, "R0") == 0) {
        *value = R0;
        return 1;
    }
    if (strcmp(str, "R1") == 0) {
        *value = R1;
        return 1;
    }
    *value = get_var(str);
    return 1;
}

void execute_instruction(const char *line, int *pc, char **instructions, int num_instructions) {
    char op[64], arg1[64], arg2[64];
    int n = sscanf(line, "%63s %63s %63s", op, arg1, arg2);
    
    if (strcmp(op, "LOAD") == 0) {
        int val;
        parse_value(arg1, &val);
        R0 = val;
    }
    else if (strcmp(op, "STORE") == 0) {
        set_var(arg1, R0);
    }
    else if (strcmp(op, "ADD") == 0) {
        int val;
        parse_value(arg1, &val);
        R0 = R0 + val;
    }
    else if (strcmp(op, "SUB") == 0) {
        int val;
        parse_value(arg1, &val);
        R0 = R0 - val;
    }
    else if (strcmp(op, "MUL") == 0) {
        int val;
        parse_value(arg1, &val);
        R0 = R0 * val;
    }
    else if (strcmp(op, "DIV") == 0) {
        int val;
        parse_value(arg1, &val);
        if (val == 0) {
            fprintf(stderr, "Erro: Divisão por zero\n");
            exit(1);
        }
        R0 = R0 / val;
    }
    else if (strcmp(op, "PUSH") == 0) {
        push(R0);
    }
    else if (strcmp(op, "POP") == 0) {
        R0 = pop();
    }
    else if (strcmp(op, "STORE_R1") == 0) {
        R1 = R0;
    }
    else if (strcmp(op, "LOAD_R1") == 0) {
        R0 = R1;
    }
    else if (strcmp(op, "JMP") == 0) {
        int addr = find_label(arg1);
        if (addr == -1) {
            fprintf(stderr, "Erro: Label não encontrado: %s\n", arg1);
            exit(1);
        }
        *pc = addr;
        return;
    }
    else if (strcmp(op, "JZ") == 0) {
        if (R0 == 0) {
            int addr = find_label(arg1);
            if (addr == -1) {
                fprintf(stderr, "Erro: Label não encontrado: %s\n", arg1);
                exit(1);
            }
            *pc = addr;
            return;
        }
    }
    else if (strcmp(op, "JNZ") == 0) {
        if (R0 != 0) {
            int addr = find_label(arg1);
            if (addr == -1) {
                fprintf(stderr, "Erro: Label não encontrado: %s\n", arg1);
                exit(1);
            }
            *pc = addr;
            return;
        }
    }
    else if (strcmp(op, "LABEL") == 0) {
        add_label(arg1, *pc);
    }
    else if (strcmp(op, "SENSOR") == 0) {
        if (strcmp(arg1, "movimento") == 0) {
            R0 = movimento_sensor;
        } else if (strcmp(arg1, "hora") == 0) {
            R0 = hora_sensor;
        } else {
            fprintf(stderr, "Erro: Sensor desconhecido: %s\n", arg1);
            exit(1);
        }
    }
    else if (strcmp(op, "LAMP_ON") == 0) {
        lamp_state = 1;
        printf("[VM] Lâmpada LIGADA\n");
    }
    else if (strcmp(op, "LAMP_OFF") == 0) {
        lamp_state = 0;
        printf("[VM] Lâmpada DESLIGADA\n");
    }
    else if (strcmp(op, "HALT") == 0) {
        *pc = num_instructions;
        return;
    }
    
    (*pc)++;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo.asm> [movimento] [hora]\n", argv[0]);
        fprintf(stderr, "Exemplo: %s programa.asm 1 18\n", argv[0]);
        return 1;
    }
    
    if (argc >= 3) {
        movimento_sensor = atoi(argv[2]);
    }
    if (argc >= 4) {
        hora_sensor = atoi(argv[3]);
    }
    
    FILE *file = fopen(argv[1], "r");
    if (!file) {
        fprintf(stderr, "Erro ao abrir arquivo: %s\n", argv[1]);
        return 1;
    }
    
    char **instructions = malloc(10000 * sizeof(char*));
    int num_instructions = 0;
    char line[MAX_LINE];
    
    while (fgets(line, MAX_LINE, file)) {
        int len = strlen(line);
        while (len > 0 && (line[len-1] == '\n' || line[len-1] == '\r')) {
            line[--len] = '\0';
        }
        if (len == 0) continue;
        
        instructions[num_instructions] = malloc(strlen(line) + 1);
        strcpy(instructions[num_instructions], line);
        num_instructions++;
    }
    fclose(file);
    
    printf("=== LampVM - Executando programa ===\n");
    printf("Sensores: movimento=%d, hora=%d\n\n", movimento_sensor, hora_sensor);
    
    int pc = 0;
    int max_cycles = 100000;
    int cycles = 0;
    
    while (pc < num_instructions && cycles < max_cycles) {
        execute_instruction(instructions[pc], &pc, instructions, num_instructions);
        cycles++;
    }
    
    if (cycles >= max_cycles) {
        printf("\n[VM] Aviso: Limite de ciclos atingido\n");
    }
    
    printf("\n=== Estado Final ===\n");
    printf("R0 = %d, R1 = %d\n", R0, R1);
    printf("Lâmpada: %s\n", lamp_state ? "LIGADA" : "DESLIGADA");
    printf("Variáveis:\n");
    for (int i = 0; i < mem_count; i++) {
        printf("  %s = %d\n", memory[i].name, memory[i].value);
    }
    
    for (int i = 0; i < num_instructions; i++) {
        free(instructions[i]);
    }
    free(instructions);
    
    return 0;
}

