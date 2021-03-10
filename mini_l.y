%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>

 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 extern const char* yytext;
 int yylex();
 char empty[1] = "";
%}

%union{
  char* cval;
  int ival;

  struct Statement{
  	std::string* IR;
  }state;

  struct Expression{
  	std::string* IR;
  	std::string* ret_name;

  }expr;

}


%error-verbose
%type<ival> NUMBER
%type<cval> IDENT

%type<expr> ident
%type<expr> declarations declaration identifiers var vars
%type<state> statements statement
%type<expr> expression bool_exp multiplicative_expression term relation_exp relation_and_exp comp

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

function:	FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
{
    std::string temp = "func";
    temp.append($2.ret_name);
    temp.append("\n");
    temp.append($2.IR);
    temp.append($5.IR);

    std::string init_vals = $5.IR;
    int nval = 0;
    while((size_t pos = init_vals.find(".")) != std::strinf::npos){
    	init_vals.replace(pos,1,"=");
    	std::string content = ",$";
    	content.append(std::to_string(nvals++));
    	content.append("\n");
    	init_vals.replace(init_vals.find("\n", pos), 1, content);
    }
    temp.append(init_vals);
    temp.append($8.IR);
    std::string stm($11.IR);
    if(stm.find("continue") != std::string::npos){
    	printf("TODO error msg");
    }
    temp.append(stm);
    temp.append(endfunc)

}
		;

ident:		IDENT {printf("ident -> IDENT %s \n", yytext);}
		;

identifiers:	ident {printf("identifiers -> ident\n");}
		| ident COMMA identifiers {printf("identifiers -> ident COMMA identifiers\n");}
		;

declarations:		%empty
		{
			$$.ret_name = strdup(empty);
			$$.IR = strdup(empty);
		}
		| declaration SEMICOLON declarations {
			std::string temp = $1.IR;
			temp.append(#3.IR);

			$$.IR = str.dup(temp.c_str());
			$$.ret_name = strdup(empty);
		}
		;

declaration:	identifiers COLON INTEGER
 		{
 			std::string temp;
			std::string variables($1.ret_name), variable;
			bool stop = false;

			size_t prev = 0, current = 0;

			while(!stop){
				current = variables.find("|", prev);
				if(current == std::string::npos){
					temp.append(". ");
					variable = variables.substr(prev, current);
					temp.append(variable);
					temp.append("\n");
					stop = true;
				}
				else{
					size_t l = current - prev;
					temp.append(". ");
					variable = variables.substr(prev, l);
					temp.append(variable);
					temp.append("\n");
				}
			}
			$$.IR = strdup(temp.c_str());
			$$.ret_name = strdup(empty);
		}
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








