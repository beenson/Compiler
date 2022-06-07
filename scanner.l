%{

#include "y.tab.h"
int linenum = 1;
%}

TEXT    \"(\\\"|[^"])*\"
DIGIT   [0-9]
EXP     [Ee][-+]?[0-9]+

%%
<<EOF>> {return END;}
"{" {return OPENBRACES;}
"}" {return CLOSEBRACES;}
"[" {return OPSB;}
"]" {return CLSB;}
"null" {return NIL;}
{TEXT} {char *temp = malloc(sizeof(char) * strlen(yytext)); strncpy(temp, yytext + 1, strlen(yytext) - 2); yylval = strdup(temp); return TEXT;}
[+-]?{DIGIT}+\.?{DIGIT}*{EXP}? {yylval = strdup(yytext); return NUMBER;}
(true|false) {yylval = strdup(yytext); return BOOLEAN;}
":" {return COLON;}
"," {return CMM;}
\n {linenum++;}
[ \t\r]+          /* eat up whitespace */

.           {printf( "Unrecognized character: %s\n", yytext ); return CH;}

%%
