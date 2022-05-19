%{

#include <ctype.h>
#include <stdio.h>
void yyerror(char *);
int yylex(void);
extern FILE *yyin;
extern int linenum;
%}

%token TEXT
%token DIGIT
%token EXP 
%token BOOLEAN
%token OPENBRACES CLOSEBRACES
%token OPSB CLSB
%token NIL
%token COLON
%token CMM
%token CH
%token NUMBER
%token END
%%



s 
: obj END 
{printf("Syntax correct!!\n"); fclose(yyin); return 0;}
;

obj
: OPENBRACES pairlist CLOSEBRACES
//{printf("rule 2\n");}
;

pairlist 
: pair CMM pairlist 
//{printf("rule 3\n");}
| pair
//{printf("rule 4\n");}
;

pair
: key COLON value
//{printf("rule 5\n");}
;

key
: TEXT
//{printf("rule 6\n");}
;

value
: obj
//{printf("rule 7\n");}
| array
//{printf("rule 8\n");}
| TEXT
//{printf("rule 9\n");}
| NIL
//{printf("rule 10\n");}
| NUMBER
//{printf("rule 11\n");}
| BOOLEAN
//{printf("rule 12\n");}
;

array 
: OPSB valuelist CLSB
//{printf("rule 13\n");}
;

valuelist 
: value CMM valuelist
//{printf("rule 14\n");}
| value
//{printf("rule 15\n");}
;


%%

void yyerror(char* s){
	fprintf(stderr, "error: %s\n", s);
	printf("Syntax error!!\nMistake line: %d\n", linenum);
	exit(1);
}

int yywrap(){
	return 1;
}

int main(int argc, char* argv[])

{
    if ( argc == 2 )
            yyin = fopen( argv[1], "r" );
    yyparse();

    return 0;

}