%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int tempCount = 0;
int varCount = 0;
FILE *yyin;

char tac[1000][100];
int tacIndex = 0;

struct VarTable {
    char name[100];
    int value;
} varTable[100];

int getVarIndex(char *name) {
    for (int i = 0; i < varCount; i++) {
        if (strcmp(varTable[i].name, name) == 0) return i;
    }
    strcpy(varTable[varCount].name, name);
    varTable[varCount].value = 0;
    return varCount++;
}

int getVarValue(char *name) {
    return varTable[getVarIndex(name)].value;
}

void setVarValue(char *name, int value) {
    varTable[getVarIndex(name)].value = value;
}

char* newTemp() {
    char* temp = (char*)malloc(10);
    sprintf(temp, "t%d", tempCount++);
    return temp;
}

void yyerror(const char *s) {
    fprintf(stderr, "\nError: %s\n", s);
}

int yylex();
%}

%union {
    int ival;
    char sval[100];
    char *tacName;
}

%token <ival> NUMBER
%token <sval> ID
%token IF ELSE WHILE PRINT
%token EQ NE LE GE LT GT
%token ASSIGN SEMI
%token LPAREN RPAREN LBRACE RBRACE
%type <tacName> expression

// Precedence rules to fix shift/reduce conflicts
%left ELSE
%left '+' '-'
%left '*' '/'

%%

program:
    program statement
  | /* empty */
;

statement:
    ID ASSIGN expression SEMI {
        sprintf(tac[tacIndex++], "%s = %s", $1, $3);
        setVarValue($1, atoi($3));
    }
  | PRINT ID SEMI {
        sprintf(tac[tacIndex++], "print %s", $2);
        printf("\n%s = %d\n", $2, getVarValue($2));
    }
  | IF LPAREN expression RPAREN statement %prec ELSE {
        sprintf(tac[tacIndex++], "if (%s) {...}", $3);
    }
  | IF LPAREN expression RPAREN statement ELSE statement {
        sprintf(tac[tacIndex++], "if (%s) {...} else {...}", $3);
    }
  | WHILE LPAREN expression RPAREN statement {
        sprintf(tac[tacIndex++], "while (%s) {...}", $3);
    }
  | LBRACE program RBRACE
;

expression:
    expression '+' expression {
        char *temp = newTemp();
        sprintf(tac[tacIndex++], "%s = %s + %s", temp, $1, $3);
        $$ = temp;
    }
  | expression '-' expression {
        char *temp = newTemp();
        sprintf(tac[tacIndex++], "%s = %s - %s", temp, $1, $3);
        $$ = temp;
    }
  | expression '*' expression {
        char *temp = newTemp();
        sprintf(tac[tacIndex++], "%s = %s * %s", temp, $1, $3);
        $$ = temp;
    }
  | expression '/' expression {
        char *temp = newTemp();
        sprintf(tac[tacIndex++], "%s = %s / %s", temp, $1, $3);
        $$ = temp;
    }
  | NUMBER {
        char *temp = (char*)malloc(10);
        sprintf(temp, "%d", $1);
        $$ = temp;
    }
  | ID {
        $$ = strdup($1);
    }
  | LPAREN expression RPAREN {
        $$ = $2;
    }
;

%%

int main() {
    yyin = fopen("input.c", "r");
    if (!yyin) {
        printf("Cannot open input.c\n");
        return 1;
    }
    yyparse();

    printf("\n--- Three Address Code (TAC) ---\n");
    for (int i = 0; i < tacIndex; i++) {
        printf("%s\n", tac[i]);
    }

    printf("\n--- Final Variable Values ---\n");
    for (int i = 0; i < varCount; i++) {
        printf("%s = %d\n", varTable[i].name, varTable[i].value);
    }

    return 0;
}
