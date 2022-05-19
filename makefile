all: yacc lex
	gcc lex.yy.c y.tab.c -o parser

yacc: parser.y
	yacc -d parser.y

lex: scanner.l
	lex scanner.l

clean:
	rm -f lex.yy.c
	rm -f scanner
	rm -f y.tab.c
	rm -f y.tab.h	
	rm -f parser
