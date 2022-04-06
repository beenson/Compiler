%{
%}

TEXT    \"(\\\"|[^"])*\"
DIGIT   [0-9]

%%

"{" printf("Start Object: %s\n", yytext);
"}" printf("End Object: %s\n", yytext);
"[" printf("Start Array: %s\n", yytext);
"]" printf("End Array: %s\n", yytext);
{TEXT} printf("Get Text: %s\n", yytext);
{DIGIT}* printf("Get Number: %s\n", yytext);
(true|false) printf("Get Boolean: %s\n", yytext);
":" printf("Is: %s\n", yytext);
"," printf("Next: %s\n", yytext);

[ \t\n]+          /* eat up whitespace */

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