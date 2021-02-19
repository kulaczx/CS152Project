%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>

 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 extern const char* yytext;
 int yylex();
%}

%union{
  char* cval;
  int ival;
}


%error-verbose
%type<ival> NUMBER
%type<cval> IDENT
%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token BREAK
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE
%token RETURN

%left SUB
%left ADD
%left MULT
%left DIV
%left MOD

%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN

%token IDENT
%token NUMBER


%right ASSIGN
%right NOT
%nonassoc UMINUS

%start program

%%


program:	functions {printf("prog_start -> functions\n");}
		;

functions:		{printf("functions -> epsilon\n");}
		| function functions  {printf("functions -> function functions\n");}
		;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
		;

ident:		IDENT {printf("ident -> IDENT %s \n", $1);}
		;

identifiers:	ident {printf("identifiers -> ident\n");}
		| ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");}
		;

declarations:		{printf("declarations -> epsilon\n");}
		| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
		;

declaration:	identifiers COLON INTEGER {printf("declaration -> identifiers COLON INTEGER\n");}
		| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
		
		;

statements:		{printf("statements -> epsilon\n");}
		| statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
		;

statement:	WRITE vars {printf("statement -> WRITE vars\n");}
		| IF bool_exp THEN statements ENDIF {printf("statement -> IF bool_exp THEN statements ENDIF\n");}
		| IF bool_exp THEN statements ELSE statements ENDIF {printf("statement -> IF bool_expr THEN statements ELSE statements ENDIF\n");}
         	| WHILE bool_exp BEGINLOOP statements ENDLOOP {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
		| BREAK {printf("statement -> BREAK\n");}
		| DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
		| RETURN expression {printf("statement ->RETURN expression\n");}
		| READ vars {printf("statement -> READ vars\n");}
		| var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
		;

bool_exp:	relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
		;

relation_and_exp:  relation_exp {printf("relation_and_exp -> relation_exp\n");}
		   ;

relation_exp:	expression comp	expression {printf("relation_exp -> expression comp expression\n");}
		| TRUE {printf("relation_exp -> TRUE\n");}
		| FALSE {printf("relation_exp -> FALSE\n");}
             	| L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_expr R_PAREN\n");}
		| NOT expression comp expression {printf("relation_exp -> NOT expression comp expression\n");}
             	| NOT TRUE {printf("relation_exp -> NOT TRUE\n");}
             	| NOT FALSE {printf("relation_exp -> NOT FALSE\n");}
             	| NOT L_PAREN bool_exp R_PAREN {printf("relation_exp -> NOT L_PAREN bool_expr R_PAREN\n");}
		;

expression:	multiplicative_expression {printf("expression -> multiplicative_expression\n");}
		| multiplicative_expression ADD multiplicative_expression {printf("expression -> multiplicative_expression ADD multiplicative_expression\n");}
		| multiplicative_expression SUB multiplicative_expression {printf("expression -> multiplicative_expression SUB multiplicative_expression\n");}
		;

multiplicative_expression:    term {printf("multiplicative_expression -> term\n");}
			| term MOD term {printf("multiplicative_expression -> term MOD term\n");}
			| term MULT term {printf("multiplicative_expr -> term MULT term\n");}
                   	| term DIV term {printf("multiplicative_expr -> term DIV term\n");}
			;


comp:		EQ {printf("comp -> EQ\n");}
		| GTE {printf("comp -> GTE\n");}
		|  NEQ {printf("comp -> NEQ\n");}
   		|  LT {printf("comp -> LT\n");}
   		|  GT {printf("comp -> GT\n");}
   		|  LTE {printf("comp -> LTE\n");}
		;

term:		var {printf("term -> var\n");}
		| NUMBER {printf("term -> NUMBER\n");}
		| SUB var {printf("term -> SUB var\n");}
		| SUB NUMBER {printf("term -> SUB NUMBER\n");}
		| SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}	
		| ident L_PAREN expression R_PAREN {printf("term -> identifier L_PAREN expression R_PAREN \n");}
		;

var:	    ident {printf("var -> ident\n");}
	    | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
	    ;

vars: var {printf("vars -> var\n");}
    | var COMMA vars {printf("vars -> var COMMA vars\n");}
    ;

%%

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("Line %d, position %d: %s\n", currLine, currPos, msg);
}








