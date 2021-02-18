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

%token SUB
%token ADD
%token MULT
%token DIV
%token MOD

%token EQ
%token NEQ
%token LT
%token GT
%token LTE
%token GTE

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
%right UMINUS


%%


program:	functions {printf("prog_start -> functions\n");}
		;

functions:		{printf("functions -> epsilon\n");}
		| function functions  {printf("functions -> function functions\n");}
		;

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
		;

ident:		IDENT {printf("ident -> IDENT %s\n", $1);}
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
		| BREAK {printf("statement -> BREAK\n");}
		| DO BEGINLOOP statements ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
		| READ vars {printf("statement -> READ vars\n");}
		| var ASSIGN expression {printf("statement -> var ASSIGN expression\n");}
		;

bool_exp:	relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
		;

relation_and_exp:  relation_exp {printf("relation_and_exp -> relation_exp\n");}
		   ;

relation_exp:	expression comp	expression {printf("relation_exp -> expression comp expression\n");}
		| TRUE {printf("relation_exp -> TRUE\n");}
		;

expression:	multiplicative_expression {printf("expression -> multiplicative_expression\n");}
		| multiplicative_expression ADD multiplicative_expression {printf("expression -> multiplicative_expression ADD multiplicative_expression\n");}
		| multiplicative_expression SUB multiplicative_expression {printf("expression -> multiplicative_expression SUB multiplicative_expression\n");}
		;

multiplicative_expression:    term {printf("multiplicative_expression -> term\n");}
			| term MOD term {printf("multiplicative_expression -> term MOD term\n");}
			;


comp:		EQ {printf("comp -> EQ\n");}
		| GTE {printf("comp -> GTE\n");}
		;

term:		var {printf("term -> var\n");}
		| NUMBER {printf("term -> NUMBER\n");}
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








