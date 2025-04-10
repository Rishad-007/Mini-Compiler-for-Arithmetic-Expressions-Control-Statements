%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"print"     { return PRINT; }
"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }
"<"         { return LT; }
">"         { return GT; }
"="         { return ASSIGN; }
";"         { return SEMI; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
[0-9]+      { yylval.ival = atoi(yytext); return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { strcpy(yylval.sval, yytext); return ID; }
[ \t\n]     ;
.           { return *yytext; }
%%
int yywrap() { return 1; }
