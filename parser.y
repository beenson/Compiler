%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
void yyerror(char *);
int yylex(void);
extern FILE *yyin;
extern int linenum; //行數
FILE *out; //輸出檔案
char *temp; //暫存label的名字
int step = 0; //階層（用來輸出tab）
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
: {printf("<root>"); step++;} obj {printf("</root>\n");} END 
{printf("Syntax correct!!\n"); fclose(yyin); return 0;}
;

obj
: {printf("\n");} OPENBRACES pairlist CLOSEBRACES
;

pairlist 
: pair CMM pairlist 
| pair
;

pair
: key NIL
{ PrintTab(step); printf("<%s />\n", $1);} 
| key {PrintTab(step); printf("<%s>", $1);} value
{printf("</%s>\n", $1);} 
| key {PrintTab(step); printf("<%s>", $1); temp = strdup($1);} OPSB valuelist CLSB
{printf("</%s>\n", $1);} 
;

key
: TEXT {$$ = yylval;} COLON
;

value
:{step++;} obj {step--; PrintTab(step);}
| TEXT
{printf("%s", $1);}
| NIL
{printf("%s", $1);}
| NUMBER
{printf("%s", $1);}
| BOOLEAN
{printf("%s", $1);}
;

valuelist 
: value CMM {printf("</%s>\n", temp); PrintTab(step); printf("<%s>", temp);}  valuelist
| value
;


%%
//輸出tab
void PrintTab(int times){
    for (int i = 0; i < times; i++) {
        printf("\t");
    }
}

void yyerror(char* s){
	fprintf(stderr, "error: %s\n", s);
	printf("Syntax error!!\nMistake line: %d\n", linenum);
	exit(1);
}

int yywrap(){
	return 1;
}

int main(int argc, char* argv[]){
	if ( argc == 2 )
	        yyin = fopen(argv[1], "r");
	argv[1][strlen(argv[1]) - 4] = 'x';
	argv[1][strlen(argv[1]) - 3] = 'm';
	argv[1][strlen(argv[1]) - 2] = 'l';
	argv[1][strlen(argv[1]) - 1] = '\0';
	out = fopen(argv[1], "w");
	yyparse();
	return 0;

}