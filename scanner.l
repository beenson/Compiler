%{
%}

TEXT    \"(\\\"|[^"])*\"
DIGIT   [0-9]
EXP     [Ee][-+]?[0-9]+

%%

"{" printf("Object Start: %s\n", yytext);
"}" printf("Object End: %s\n", yytext);
"[" printf("Array Start: %s\n", yytext);
"]" printf("Array End: %s\n", yytext);
"null" printf("Null Object: %s\n", yytext);
{TEXT} printf("Get Text: %s\n", yytext);
[+-]?{DIGIT}+\.?{DIGIT}*{EXP}? printf("Get Number: %s\n", yytext);
(true|false) printf("Get Boolean: %s\n", yytext);
":" printf("Is: %s\n", yytext);
"," printf("Next: %s\n", yytext);

[ \t\r\n]+          /* eat up whitespace */

.           printf( "Unrecognized character: %s\n", yytext );

%%

main( argc, argv )
int argc;
char **argv;
    {
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            yyin = fopen( argv[0], "r" );
    else
            yyin = stdin;

    yylex();
    }