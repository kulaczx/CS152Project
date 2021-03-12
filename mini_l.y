%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <iostream>
 #include <string>
 #include <vector>
 #include <sstream> 
 
void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 extern const char* yytext;
 int yylex();
 char empty[1] = "";
 std::string Temp2();
 std::string Label2();
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

  static std::vector<std::string> reservedWords = {"FUNCTION", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", "END_BODY", "INTEGER", "ARRAY", "OF", "IF", "THEN", "ENDIF", "ELSE", "WHILE", "DO", "FOR", "BEGINLOOP", "ENDLOOP", "CONTINUE", "READ", "WRITE", "TRUE", "FALSE", "RETURN", "SEMICOLON", "COLON", "COMMA", "L_PAREN", "R_PAREN", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "ASSIGN", "IDENT", "NUMBER", "ERROR", "IDENT", "NUMBER", "ASSIGN", "OR", "AND", "NOT", "LT", "LTE", "GT", "GTE", "EQ", "NEQ", "ADD", "SUB", "MULT", "DIV", "MOD", "UMINUS", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_PAREN", "R_PAREN", "function", "begin_params", "end_params", "begin_locals", "end_locals", "begin_body", "end_body", "integer", "array", "of", "if", "then", "endif", "else", "while", "do", "for", "beginloop", "endloop", "continue", "read", "write", "true", "false", "return", "semicolon", "colon", "comma", "l_paren", "r_paren", "l_square_bracket", "r_square_bracket", "assign", "ident", "number", "error", "ident", "number", "assign", "or", "and", "not", "lt", "lte", "gt", "gte", "eq", "neq", "add", "sub", "mult", "div", "mod", "uminus", "l_square_bracket", "r_square_bracket", "l_paren", "r_paren"};

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


program:	functions {}
		;

functions:	
		| function functions  {}
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
    temp.append("endfunc\n");

}
		;

ident:		IDENT {
			$$ = $1;
		}
		;

identifiers:	ident {
			$$.ret_name = strdup($1.ret_name);
                        $$.IR = strdup(empty);
		}
		| ident COMMA identifiers {
			std::string temp;
			temp.append($1.ret_name);
			temp.append("|");
			temp.append($3.ret_name);

			$$.ret_name = strdup(temp.c_str());
			$$.IR = strdup(empty);
		}
		;

declarations:		%empty
		{
			$$.ret_name = strdup(empty);
			$$.IR = strdup(empty);
		}
		| declaration SEMICOLON declarations {
			std::string temp = $1.IR;
			temp.append($3.IR);

			$$.IR = strdup(temp.c_str());
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
					stop = false;
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

statements:		{
			$$ = "";
		}
		| statement SEMICOLON statements {
			$$ = $1 + "\n" + $3;
		}
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

bool_exp:	relation_and_exp {
			$$ = $1;
		}
		;

relation_and_exp:  relation_exp {printf(
			$$ = $1;
		}
		;

relation_exp:	expression comp	expression {
			std::string temp;
			std::string temp2 = Temp2();
			temp.append($1.IR);
  			temp.append($3.IR);
  			temp.append(". ");
  			temp.append(temp2);
  			temp.append("\n");
  			temp.append($2.ret_name);
  			temp.append(dest);
  			temp.append(", ");
  			temp.append($1.ret_name);
  			temp.append(", ");
  			temp.append($3.ret_name);
  			temp.append("\n");
  			$$.IR = strdup(temp.c_str());
  			$$.ret_name = strdup(temp2.c_str());
		}
		| TRUE {
			char temp[2] = "1";
			$$.ret_name = strdup(temp);
			$$.IR = strdup(empty);
		}
		| FALSE {printf(
			char temp[2] = "0";
			$$.ret_name = strdup(temp);
			$$.IR = strdup(empty);
		}
             	| L_PAREN bool_exp R_PAREN {
			$$.ret_name = strdup($2.ret_name);
  			$$.IR = strdup($2.IR);
		}
		| NOT expression comp expression {
			std::string temp2 = Temp2();
  			std::string temp;
 		 	temp.append($2.IR);
  			temp.append(". ");
  			temp.append(temp2);
  			temp.append("\n");
 			temp.append("! ");
  			temp.append(temp2);
  			temp.append(", ");
  			temp.append($2.ret_name);
  			temp.append("\n");
  			$$.IR = strdup(temp.c_str());
  			$$.ret_name = strdup(temp2.c_str());	
		}
             	| NOT TRUE {}
             	| NOT FALSE {}
             	| NOT L_PAREN bool_exp R_PAREN {}
		;

expression:	multiplicative_expression {
			$$.IR = strdup($1.IR);
  			$$.ret_name = strdup($1.ret_name);
		}
		| multiplicative_expression ADD multiplicative_expression {
			$$.ret_name = strdup(Temp2().c_str());
  			std::string temp;
  			temp.append($1.IR);
  			temp.append($3.IR);
  			temp.append(". ");
  			temp.append($$.ret_name);
  			temp.append("\n");
  			temp.append("+ ");
  			temp.append($$.ret_name);
  			temp.append(", ");
  			temp.append($1.ret_name);
  			temp.append(", ");
  			temp.append($3.ret_name);
  			temp.append("\n");
  			$$.IR = strdup(temp.c_str());
		}
		| multiplicative_expression SUB multiplicative_expression {
			$$.ret_name = strdup(Temp2().c_str());
                        std::string temp;
                        temp.append($1.IR);
                        temp.append($3.IR);
                        temp.append(". ");
                        temp.append($$.ret_name);
                        temp.append("\n");
                        temp.append("- ");
                        temp.append($$.ret_name);
                        temp.append(", ");
                        temp.append($1.ret_name);
                        temp.append(", ");
                        temp.append($3.ret_name);
                        temp.append("\n");
                        $$.IR = strdup(temp.c_str());
		}
		;

multiplicative_expression:    term {printf(
				$$.IR = strdup($1.IR);
				$$.ret_name = strdup($1.place);
			}
			| term MOD term {
				$$.ret_name = strdup(Temp2().c_str());
  				std::string temp;
  				temp.append(". ");
  				temp.append($$.ret_name);
  				temp.append("\n");
  				temp.append($1.IR);
  				temp.append($3.IR);
  				temp.append("% ");
  				temp.append($$.ret_name);
  				temp.append(", ");
  				temp.append($1.ret_name);
  				temp.append(", ");
  				temp.append($3.ret_name);
  				temp.append("\n");
  				$$.IR = strdup(temp.c_str());
			}
			| term MULT term {printf(
				$$.ret_name = strdup(Temp2().c_str());
                                std::string temp;
                                temp.append(". ");
                                temp.append($$.ret_name);
                                temp.append("\n");
                                temp.append($1.IR);
                                temp.append($3.IR);
                                temp.append("* ");
                                temp.append($$.ret_name);
                                temp.append(", ");
                                temp.append($1.ret_name);
                                temp.append(", ");
                                temp.append($3.ret_name);
                                temp.append("\n");
                                $$.IR = strdup(temp.c_str());
			}
                   	| term DIV term {printf(
				$$.ret_name = strdup(Temp2().c_str());
                                std::string temp;
                                temp.append(". ");
                                temp.append($$.ret_name);
                                temp.append("\n");
                                temp.append($1.IR);
                                temp.append($3.IR);
                                temp.append("% ");
                                temp.append($$.ret_name);
                                temp.append(", ");
                                temp.append($1.ret_name);
                                temp.append(", ");
                                temp.append($3.ret_name);
                                temp.append("\n");
                                $$.IR = strdup(temp.c_str());
			}
			;


comp:		EQ {
			$$ = "==";
		}
		| GTE {
			$$ = ">=";
		}
		|  NEQ {
			$$ = "!=";
		}
   		|  LT {
			$$ = "<";
		}
   		|  GT {
			$$ = ">";
		}
   		|  LTE {
			$$ = "<=";
		}
		;

term:		var {
			$$.ret_name = Temp2();
			$$.IR += ". " + $$.ret_name + "\n";
		}
		| NUMBER {
			int val = int($1);
			$$.ret_name = Temp2();
			$$.IR += std::to_string(val);
		}
		| SUB var {
			$$.ret_name = Temp2();
			$$.IR += ". " + $$.ret_name + "\n";
		}
		| SUB NUMBER {
			$$.ret_name = Temp2();
			$$.IR += ". " + $$.ret_name + "\n";
			$$.IR = "-1 * ";
			$$.IR += $2;
			$$.IR += "\n";
		}
		| SUB L_PAREN expression R_PAREN {
			$$.ret_name = Temp2();
			$$.IR += ". " + $$.ret_name + "\n";
			$$.IR = "(" + $3.ret_name + ")" + "\n" + $3.IR;
		}	
		| ident L_PAREN expression R_PAREN {
			$$.ret_name = Temp2();
                        $$.IR += ". " + $$.ret_name + "\n"; 
			$$.IR += $1 + $3.ret_name + $3.IR;
		}
		;

var:	    ident {
			$$.IR = strdup(empty);
  			$$.ret_name = strdup($1.ret_name);
		}	
	    | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
			std::string temp;
  			temp.append($1.ret_name);
  			temp.append(", ");
  			temp.append($3.IR);
  			$$.IR = strdup($3.IR);
  			$$.ret_name = strdup(temp.c_str());
		}
	    ;

vars: var {
			std::string temp;
			temp.append($1.IR);
			temp.append(".| ");
			temp.append($1.ret_name);
  			temp.append("\n");
  			$$.IR = strdup(temp.c_str());
  			$$.ret_name = strdup(empty);
		}
    | var COMMA vars {
			std::string temp;
                        temp.append($1.IR);
                        temp.append(".| ");
                        temp.append($1.ret_name);
                        temp.append("\n");
			temp.append($3.IR);
                        $$.IR = strdup(temp.c_str());
                        $$.ret_name = strdup(empty);
		}
    ;

%%

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
   printf("Line %d, position %d: %s\n", currLine, currPos, msg);
}

std::string Temp2() {
  static int num = 0;
  std::string temp = "_temp_" + std::to_string(++num);
  return temp;
}

std::string Label2() {
  static int num = 0;
  std::string temp = "L" + std::to_string(++num);
  return temp;
}






