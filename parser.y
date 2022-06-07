%{
	#include <ctype.h>
	#include <stdio.h>
	#include <string.h>
	void yyerror(char *);
	int yylex(void);
	extern FILE *yyin;
	extern int linenum; //行數
	FILE *out; //輸出檔案
	FILE* myStream;
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
: {fprintf(myStream, "<root>"); step++;} obj {fprintf(myStream, "</root>\n");} END 
{printf("Syntax correct!!\n"); fclose(yyin); return 0;}
;

obj
: {fprintf(myStream, "\n");} OPENBRACES pairlist CLOSEBRACES
;

pairlist 
: pair CMM pairlist 
| pair
;

pair
: key NIL
{ PrintTab(step); fprintf(myStream, "<%s />\n", $1);} 
| key {PrintTab(step); fprintf(myStream, "<%s>", $1);} value
{fprintf(myStream, "</%s>\n", $1);} 
| key {PrintTab(step); fprintf(myStream, "<%s>", $1); temp = strdup($1);} OPSB valuelist CLSB
{fprintf(myStream, "</%s>\n", $1);} 
;

key
: TEXT {$$ = yylval;} COLON
;

value
:{step++;} obj {step--; PrintTab(step);}
| TEXT
{fprintf(myStream, "%s", $1);}
| NIL
{fprintf(myStream, "%s", $1);}
| NUMBER
{fprintf(myStream, "%s", $1);}
| BOOLEAN
{fprintf(myStream, "%s", $1);}
;

valuelist 
: value CMM {fprintf(myStream, "</%s>\n", temp); PrintTab(step); fprintf(myStream, "<%s>", temp);}  valuelist
| value
;


%%
//輸出tab
void PrintTab(int times){
    for (int i = 0; i < times; i++) {
        fprintf(myStream, "\t");
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

	char* buffer = NULL;
	size_t bufferSize = 0;
	myStream = open_memstream(&buffer, &bufferSize);

	yyparse();
	
	fclose(myStream);
	argv[1][strlen(argv[1]) - 4] = 'x';
	argv[1][strlen(argv[1]) - 3] = 'm';
	argv[1][strlen(argv[1]) - 2] = 'l';
	argv[1][strlen(argv[1]) - 1] = '\0';
	out = fopen(argv[1], "w");
	fprintf(out, "%s", buffer);
	fclose(out);
	free(buffer);

	return 0;
}