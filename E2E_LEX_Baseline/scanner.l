/* QuectoC Level 1: complete reference scanner. */
%option noyywrap noinput nounput never-interactive nodefault
%{
#include <stdio.h>
static void emit(const char *kind);
%}
%%
"let"                   { emit("KW_LET"); }
"int"                   { emit("KW_INT"); }
"print"                 { emit("KW_PRINT"); }
[A-Za-z_][A-Za-z0-9_]*    { emit("IDENTIFIER"); }
[0-9]+                  { emit("INT_LITERAL"); }
"="                     { emit("ASSIGN"); }
"+"                     { emit("PLUS"); }
"-"                     { emit("MINUS"); }
";"                     { emit("SEMICOLON"); }
"("                     { emit("LPAREN"); }
")"                     { emit("RPAREN"); }
"//"[^\n]*              { /* Skip through the end of this line. */ }
[ \t\r\n]+              { /* Skip separating text. */ }
.                       { emit("LEX_ERROR"); }
%%
static void emit(const char *kind) {
    printf("%s  %s\n", kind, yytext);
}
int main(void) {
    yylex();
    yylex_destroy();
    return 0;
}
