%{
   #include "y.tab.h"   
   int currLine = 1, currPos = 0;
%}

DIGIT               [0-9]
LETTER              [a-zA-Z]
LETTER_UNDERSCORE   [a-zA-Z_]
DIGIT_UNDERSCORE    [0-9_]
CHAR                [0-9a-zA-Z_]
DIGIT_OR_LETTER     [0-9a-zA-Z]
COM	##.*[\n]

%%

"function"	{printf("FUNCTION\n"); currPos+= yyleng;}
"beginparams"	{printf("BEGIN_PARAMS\n");currPos+=yyleng;}
"endparams"	{printf("END_PARAMS\n");currPos+=yyleng;}
"beginlocals"	{printf("BEGIN_LOCALS\n");currPos+=yyleng;}
"endlocals"	{printf("END_LOCALS\n");currPos+=yyleng;}
"beginbody"	{printf("BEGIN_BODY\n");currPos+=yyleng;}
"endbody"	{printf("END_BODY\n");currPos+=yyleng;}
"integer"	{printf("INTEGER\n");currPos+=yyleng;}
"array"		{printf("ARRAY\n");currPos+=yyleng;}
"of"		{printf("OF\n");currPos+=yyleng;}
"if"		{printf("IF\n");currPos+=yyleng;}
"then"		{printf("THEN\n");currPos+=yyleng;}
"endif"		{printf("ENDIF\n");currPos+=yyleng;}
"else"		{printf("ELSE\n");currPos+=yyleng;}
"while"		{printf("WHILE\n");currPos+=yyleng;}
"do"		{printf("DO\n");currPos+=yyleng;}
"beginloop"     {printf("BEGINLOOP\n");currPos+=yyleng;}
"endloop"       {printf("ENDLOOP\n");currPos+=yyleng;}
"break"         {printf("BREAK\n");currPos+=yyleng;}
"read"          {printf("READ\n");currPos+=yyleng;}
"write"         {printf("WRITE\n");currPos+=yyleng;}
"and"           {printf("AND\n");currPos+=yyleng;}
"or"		{printf("OR\n");currPos+=yyleng;}
"not"		{printf("NOT\n");currPos+=yyleng;}
"true"		{printf("TRUE\n");currPos+=yyleng;}
"false"		{printf("FALSE\n");currPos+=yyleng;}
"return"	{printf("RETURN\n");currPos+=yyleng;}

"-"		{printf("SUB\n");currPos++;}
"+"             {printf("ADD\n");currPos++;}
"*"             {printf("MULT\n");currPos++;}
"/"             {printf("DIV\n");currPos++;}
"%"             {printf("MOD\n");currPos++;}

"=="		{printf("EQ\n");currPos+=2;}
"<>"            {printf("NEQ\n");currPos+=2;}
"<"             {printf("LT\n");currPos+=2;}
">"             {printf("GT\n");currPos+=2;}
"<="            {printf("LTE\n");currPos+=2;}
">="            {printf("GTE\n");currPos+=2;}

";" 		{printf("SEMICOLON\n");currPos++;}
":"             {printf("COLON\n");currPos++;}
","             {printf("COMMA\n");currPos++;}
"("             {printf("L_PAREN\n");currPos++;}
")"             {printf("R_PAREN\n");currPos++;}
"["             {printf("L_SQUARE_BRACKET\n");currPos++;}
"]"             {printf("R_SQUARE_BRACKET\n");currPos++;}
":="            {printf("ASSIGN\n");currPos++;}

{COM}		currPos++; currPos= 0;	
{LETTER}({CHAR}*{DIGIT_OR_LETTER}+)?		{currPos+=yyleng; return IDENT;}
{DIGIT}+	{currPos+=yyleng; return NUMBER;}

{DIGIT}+{LETTER_UNDERSCORE}+{DIGIT_OR_LETTER}*     {printf("Error at line %i, column %i: identifier \"%s\" must begin with a letter\n",currLine, currPos, yytext);currPos+=yyleng;exit(0);}
[_]+[a-zA-Z_0-9]*                                  {printf("Error at line %i, column %i: identifier \"%s\" must begin with a letter\n",currLine, currPos, yytext);currPos+=yyleng;exit(0);}
[a-zA-Z_0-9]*[_]+             {printf("Error at line %i, column %i: identiifier \"%s\" cannot end with a underscore\n",currLine, currPos, yytext);currPos+=yyleng;exit(0);}



[ \t]+         {/* ignore spaces */ currPos += yyleng;}
"\n"           {currLine++; currPos = 0;}
.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}


%%

