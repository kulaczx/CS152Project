all: lexer

run: all
	./lexer

lexer: flexfile
	gcc -o lexer lex.yy.c -lfl

flexfile: mini_1.lex
	flex mini_1.lex
