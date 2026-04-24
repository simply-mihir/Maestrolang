%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option yylineno
%option noyywrap

%%

"/*"([^*]|\*+[^*/])*\*+"/"  { /* ignore multi-line comments */ }
"//".*                      { /* ignore single-line comments */ }
[ \t\r\n]+                  { /* ignore whitespace */ }

"Track"                 { return TRACK; }
"Tempo"                 { return TEMPO; }
"Play"                  { return PLAY; }
"Chord"                 { return CHORD; }
"Repeat"                { return REPEAT; }
"Define"                { return DEFINE; }
"PlayMacro"             { return PLAYMACRO; }

"quarter"               { yylval.str = strdup(yytext); return QUARTER; }
"half"                  { yylval.str = strdup(yytext); return HALF; }
"whole"                 { yylval.str = strdup(yytext); return WHOLE; }
"eighth"                { yylval.str = strdup(yytext); return EIGHTH; }

[A-G][b#]?[0-9]         { yylval.str = strdup(yytext); return NOTE_TOK; }
[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }
\"[^\"]*\"              { yylval.str = strdup(yytext); return STRING; }
[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return IDENTIFIER; }

"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"["                     { return LBRACKET; }
"]"                     { return RBRACKET; }
";"                     { return SEMICOLON; }
","                     { return COMMA; }

.                       { printf("Lexical Error at line %d: Unrecognized character '%s'\n", yylineno, yytext); exit(1); }

%%
