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

"function"	{currPos+= yyleng; return FUNCTION;}
"beginparams"	{currPos+=yyleng; return BEGIN_PARAMS;}
"endparams"	{currPos+=yyleng; return END_PARAMS;}
"beginlocals"	{currPos+=yyleng; return BEGIN_LOCALS;}
"endlocals"	{currPos+=yyleng; return END_LOCALS;}
"beginbody"	{currPos+=yyleng; return BEGIN_BODY;}
"endbody"	{currPos+=yyleng; return END_BODY;}
"integer"	{currPos+=yyleng; return INTEGER;}
"array"		{currPos+=yyleng; return ARRAY;}
"of"		{currPos+=yyleng; return OF;}
"if"		{currPos+=yyleng; return IF;}
"then"		{currPos+=yyleng; return THEN;}
"endif"		{currPos+=yyleng; return ENDIF;}
"else"		{currPos+=yyleng; return ELSE;}
"while"		{currPos+=yyleng; return WHILE;}
"do"		{currPos+=yyleng; return DO;}
"beginloop"     {currPos+=yyleng; return BEGINLOOP;}
"endloop"       {currPos+=yyleng; return ENDLOOP;}
"break"         {currPos+=yyleng; return BREAK;}
"read"          {currPos+=yyleng; return READ;}
"write"         {currPos+=yyleng; return WRITE;}
"and"           {currPos+=yyleng; return AND;}
"or"		{currPos+=yyleng; return OR;}
"not"		{currPos+=yyleng; return NOT;}
"true"		{currPos+=yyleng; return TRUE;}
"false"		{currPos+=yyleng; return FALSE;}
"return"	{currPos+=yyleng; return RETURN;}

"-"		{currPos++; return SUB;}
"+"             {currPos++; return ADD;}
"*"             {currPos++; return MULT;}
"/"             {currPos++; return DIV;}
"%"             {currPos++; return MOD;}

"=="		{currPos+=2; return EQ;}
"<>"            {currPos+=2; return NEQ;}
"<"             {currPos+=2; return LT;}
">"             {currPos+=2; return GT;}
"<="            {currPos+=2; return LTE;}
">="            {currPos+=2; return GTE;}

";" 		{currPos++; return SEMICOLON;}
":"             {currPos++; return COLON;}
","             {currPos++; return COMMA;}
"("             {currPos++; return L_PAREN;}
")"             {currPos++; return R_PAREN;}
"["             {currPos++; return L_SQUARE_BRACKET;}
"]"             {currPos++; return R_SQUARE_BRACKET;}
":="            {currPos++; return ASSIGN;}

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

