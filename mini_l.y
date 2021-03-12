%{
 #include "header.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <string>
 
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
 #include "header.h"
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
  char* cval;
  int ival;

  struct Statement{
  	std::string* IR;
  }state;

  struct Expression{
  	std::string* IR;
  	std::string* ret_name;
  	bool check;

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
			std::string v($1.ret_name), variable;
			bool stop = false;

			size_t prev = 0, current = 0;

			while(!stop){
				current = v.find("|", prev);
				if(current == std::string::npos){
					temp.append(". ");
					variable = v.substr(prev, current);
					temp.append(variable);
					temp.append("\n");
					stop = false;
				}
				else{
					size_t l = current - prev;
					temp.append(". ");
					variable = v.substr(prev, l);
					temp.append(variable);
					temp.append("\n");
				}
			}
			$$.IR = strdup(temp.c_str());
			$$.ret_name = strdup(empty);
		}
		| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		{
			std::string temp, v($1.ret_name), variable;
			bool stop = false;
			if($5 <= 0){
				char err[128];
				snprintf(temp, 128,"Error, array size less than 1");
				yyerror(temp);
			}

			size_t prev = 0, current = 0;
			while(!stop){
				current = v.find("|", prev);
				if(current == std::string::npos){
					temp.append(variable);
					temp.append(", ");
					temp.append(std::to_string($5));
					temp.append("\n");
					stop = true;
				}
				else{
					size_t l = current - prev;
					temp.append(".[] ");
					variable = v.substr(prev, l);
					temp.append(variable);
					temp.append(", ");
					temp.append(std::to_string($5));
					temp.append("\n");

				}
				variables.insert(std::pair<std::string, int>(variable, $5);

				prev = current +1;
			}

			$$.IR = strdup(temp.c_str());
			$$.ret_name = strdup(empty);

		}
		
		;

statements:		{
			$$ = "";
		}
		| statement SEMICOLON statements {
			$$ = $1 + "\n" + $3;
		}
		;

statement:	WRITE vars {
			std::string temp = $2.IR;
			size_t pos = 0;
			while(true){
				pos = temp.find("|", pos);
				if(pos == std::string::npos){break;}
				temp.replace(pos, 1, ">");
			}

			$$.IR = strdup(temp.c_str());
		}
		| IF bool_exp THEN statements ENDIF {
			std::string then = newLabel(), end = new:abel(), temp;

			temp.append($2.IR);
			temp.append("?:= ");
			temp.append(then);
			temp.append(", ");
			temp.append($2.ret_name);
			temp.append(":= ");
			temp.append(end);
			temp.append("\n");
			temp.append(": ");
			temp.append(then);
			temp.append("\n");
			temp.append($4.IR);
			temp.append(": ");
			temp.append(end);
			temp.append("\n");

			$$.IR = strdup(temp.c_str());
		}
		| IF bool_exp THEN statements ELSE statements ENDIF {
			std::string then = newLabel(), end = new:abel(), temp;

			temp.append($2.IR);
			temp.append("?:= ");
			temp.append(then);
			temp.append(", ");
			temp.append($2.ret_name);
			temp.append("\n");
			temp.append($5.IR);
			temp.append($6.IR);
			temp.append(":= ");
			temp.append(end);
			temp.append("\n");
			temp.append(": ");
			temp.append(then);
			temp.append("\n");
			temp.append($4.IR);
			temp.append(": ");
			temp.append(end);
			temp.append("\n");

			$$.IR = strdup(temp.c_str());

		}
         	| WHILE bool_exp BEGINLOOP statements ENDLOOP {
         		std::string temp, While = newLabel(), bloop = newLabel(), eLoop = newLabel();
         		std::string statement = $4.IR, jp;
         		jp.append(":= ");
         		jp.append(While);
         		while(statement.find("continue") != std::string::npos){
         			statement.replace(statement.find("continue"), 8, jp);
         		}

         		  temp.append(": ");
                          temp.append(While);
                          temp.append("\n");
                          temp.append($2.IR);
                          temp.append("?:= ");
                          temp.append(bLoop);
                          temp.append(", ");
                          temp.append($2.rett_name);
                          temp.append("\n");
                          temp.append(":= ");
                          temp.append(eLoop);
                          temp.append("\n");
                          temp.append(": ");
                          temp.append(bloop);
                          temp.append("\n");
                          temp.append(statement);
                          temp.append(":= ");
                          temp.append(While);
                          temp.append("\n");
                          temp.append(": ");
                          temp.append(eLoop);
                          temp.append("\n");

                          $$.IR = strdup(temp.c_str());

         	}
		| BREAK {
			std::string breakstr = "break\n";
			$$.IR = strdup(breakstr.c_str()));
		}
		| DO BEGINLOOP statements ENDLOOP WHILE bool_exp {
			std::string temp, While = newLabel(), bloop = newLabel(), eLoop = newLabel();
			std::string statement = $4.IR, jp;
			jp.append(":= ");
			jp.append(While);
			while(statement.find("continue") != std::string::npos){
				statement.replace(statement.find("continue"), 8, jp);
			}

			  temp.append(": ");
			  temp.append(bLoop);
			  temp.append("\n");
			  temp.append(statement);
			  temp.append(": ");
			  temp.append(While);
			  temp.append("\n");
			  temp.append($6.IR);
			  temp.append("?:= ");
			  temp.append(bLoop);
			  temp.append(", ");
			  temp.append($6.ret_name);
			  temp.append("\n");

			  $$.IR = strdup(temp.c_str());
		}
		| RETURN expression {
			std::string temp;
			temp.append($2.IR);
			temp.append("ret ");
			temp.append($2.ret_name);
			temp.append("\n");
			$$.code = strdup(temp.c_str());
		}
		| READ vars {
			std::string temp = $2.IR;
			size_t pos = 0;
			while(true){
				pos = temp.find("|", pos);
				if(pos == std::string::npos){break;}
				temp.replace(pos, 1, "<");
			}

			$$.IR = strdup(temp.c_str());
		}
		| var ASSIGN expression {
			std::temp;
			temp.append($1.IR);
			temp.append($3.IR);
			std::string temp2 = $3.ret_name;
			if($1.check && $3.check){
				temp2 = newTemp();
				temp.append(". ");
				temp.append(temp2);
				temp.append("\n");
				temp.append("=[] ");
				temp.append(temp2);
				temp.append(", ");
				temp.append($3.ret_name);
				temp.append("\n");
				temp.append("[]= ");

			}
			else if($1.check){
				temp.append("[]= ");
			}
			else if($3.check){
				temp.append("=[] ");
			}
			else{
				temp.append("= ");
			}
			temp.append($1.ret_name);
			temp.append(", ");
			temp.append(temp2);
			temp.append("\n");

			$$.code = strdup(teemp.c_str());
		}
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






