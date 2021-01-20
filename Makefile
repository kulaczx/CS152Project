all: lexer

run: all
	./lexer

lexer: flexfile
	gcc -o lexer lex.yy.c -lfl

flexfile: 862067482-862127794.lex
	flex 862067482-862127794.lex
