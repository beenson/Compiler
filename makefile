all:
	lex scanner.l
	gcc lex.yy.c -o scanner -ll

clean:
	rm -f lex.yy.c
	rm -f scanner