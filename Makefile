parse: 862067482-862127794.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex 862067482-862127794.lex
	g++ -std=c++11 -o parser y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser
