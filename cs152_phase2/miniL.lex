   /* cs152-miniL phase2 */

/* write your C code here for definitions of variables and including headers */  
%{ 
   #include "miniL-parser.c"
	int row_num = 1; int col_num = 0;
%}

/* some common rules, for example DIGIT */

NUM [0-9]+
IDENTIFIER_SYMBOL [_a-zA-Z0-9]

/* specific lexer rules in regex */
%%

(" "|"\t") {col_num += yyleng;} /* SPACE OR TAB*/
("\n"|##(.)*) {row_num++; col_num = 0;} /* NEW LINE OR COMMENT */

function {  col_num += yyleng; return FUNCTION; }
beginparams {  col_num += yyleng; return BEGIN_PARAMS;}
endparams {  col_num += yyleng; return END_PARAMS;}
beginlocals {  col_num += yyleng;return BEGIN_LOCALS;}
endlocals {  col_num += yyleng;return END_LOCALS; }
beginbody {  col_num += yyleng;return BEGIN_BODY; }
endbody {  col_num += yyleng;return END_BODY; }
integer {  col_num += yyleng;return INTEGER; }
array {  col_num += yyleng;return ARRAY; }
of {  col_num += yyleng;return OF; }
if {  col_num += yyleng;return IF; }
then {  col_num += yyleng;return THEN; }
endif {  col_num += yyleng;return ENDIF; }
else {  col_num += yyleng;return ELSE; }
while {  col_num += yyleng;return WHILE; }
do {  col_num += yyleng;return DO; }
beginloop {  col_num += yyleng;return BEGINLOOP; }
endloop {  col_num += yyleng;return ENDLOOP; }
continue {  col_num += yyleng;return CONTINUE; }
break {  col_num += yyleng;return BREAK; }
read {  col_num += yyleng;return READ; }
write {  col_num += yyleng;return WRITE; }
not {  col_num += yyleng;return NOT; }
true {  col_num += yyleng;return TRUE; }
false {  col_num += yyleng;return FALSE; }
return {  col_num += yyleng;return RETURN; }

"-" {  col_num += yyleng;return SUB; }
"+" {  col_num += yyleng;return ADD; }
"*" {  col_num += yyleng;return MULT; }
"/" {  col_num += yyleng;return DIV; }
"%" {  col_num += yyleng;return MOD; }

"==" {  col_num += yyleng;return EQ; }
"<>" {  col_num += yyleng;return NEQ; }
"<" {  col_num += yyleng;return LT; }
">" {  col_num += yyleng;return GT; }
"<=" {  col_num += yyleng;return LTE; }
">=" {  col_num += yyleng;return GTE; }

{NUM} {  col_num += yyleng; yylval.ival = atoi(yytext); return NUMBER; }

[0-9_]{IDENTIFIER_SYMBOL}* {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", row_num, col_num, yytext); }
{IDENTIFIER_SYMBOL}*_ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", row_num, col_num, yytext); }
{IDENTIFIER_SYMBOL}+ {  col_num += yyleng; yylval.sval = yytext; return IDENTIFIER; }

";" {  col_num += yyleng; return SEMICOLON; }
":" {  col_num += yyleng; return COLON; }
"," {  col_num += yyleng; return COMMA; }
"(" {  col_num += yyleng; return L_PAREN; }
")" {  col_num += yyleng; return R_PAREN; }
"[" {  col_num += yyleng; return L_SQUARE_BRACKET; }
"]" {  col_num += yyleng; return R_SQUARE_BRACKET; }
":=" {  col_num += yyleng; return ASSIGN; }


. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", row_num, col_num, yytext); }

%%

/* C functions used in lexer */