all: practice
bison.tab.c bison.tab.h:	bison.y
	bison -t -v -d bison.y
lex.yy.c: lexer.lex bison.tab.h
	flex lexer.lex 
practice: lex.yy.c bison.tab.c bison.tab.h
	g++ -std=c++11  -o practice bison.tab.c lex.yy.c -lfl
clean:
	rm practice bison.tab.c lex.yy.c bison.tab.h bison.output
