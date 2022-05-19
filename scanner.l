%{

#include "y.tab.h"
int linenum = 1;
%}

TEXT    \"(\\\"|[^"])*\"
DIGIT   [0-9]
EXP     [Ee][-+]?[0-9]+

%%
<<EOF>> {printf("END OF FILE\n"); return END;}
"{" {printf("Object Start: %s\n", yytext); return OPENBRACES;}
"}" {printf("Object End: %s\n", yytext); return CLOSEBRACES;}
"[" {printf("Array Start: %s\n", yytext); return OPSB;}
"]" {printf("Array End: %s\n", yytext); return CLSB;}
"null" {printf("Null Object: %s\n", yytext); return NIL;}
{TEXT} {printf("Get Text: %s\n", yytext); return TEXT;}
[+-]?{DIGIT}+\.?{DIGIT}*{EXP}? {printf("Get Number: %s\n", yytext); return NUMBER;}
(true|false) {printf("Get Boolean: %s\n", yytext); return BOOLEAN;}
":" {printf("Is: %s\n", yytext); return COLON;}
"," {printf("Next: %s\n", yytext); return CMM;}
\n {linenum++;}
[ \t\r]+          /* eat up whitespace */

.           {printf( "Unrecognized character: %s\n", yytext ); return CH;}

%%
