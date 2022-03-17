   /* cs152-miniL phase1 */

/* write your C code here for definitions of variables and including headers */  
%{ 
	int row_num = 1; int col_num = 0;
%}

/* some common rules, for example DIGIT */

INTEGER [0-9]+
IDENTIFIER_SYMBOL [_a-zA-Z0-9]

/* specific lexer rules in regex */
%%

(" "|"\t") {col_num += yyleng;} /* SPACE OR TAB*/
("\n"|##(.)*) {row_num++; col_num = 0;} /* NEW LINE OR COMMENT */

function {printf("FUNCTION\n"); col_num += yyleng;}
beginparams {printf("BEGIN_PARAMS\n"); col_num += yyleng;}
endparams {printf("END_PARAMS\n"); col_num += yyleng;}
beginlocals {printf("BEGIN_LOCALS\n"); col_num += yyleng;}
endlocals {printf("END_LOCALS\n"); col_num += yyleng;}
beginbody {printf("BEGIN_BODY\n"); col_num += yyleng;}
endbody {printf("END_BODY\n"); col_num += yyleng;}
integer {printf("INTEGER\n"); col_num += yyleng;}
array {printf("ARRAY\n"); col_num += yyleng;}
of {printf("OF\n"); col_num += yyleng;}
if {printf("IF\n"); col_num += yyleng;}
then {printf("THEN\n"); col_num += yyleng;}
endif {printf("ENDIF\n"); col_num += yyleng;}
else {printf("ELSE\n"); col_num += yyleng;}
while {printf("WHILE\n"); col_num += yyleng;}
do {printf("DO\n"); col_num += yyleng;}
beginloop {printf("BEGINLOOP\n"); col_num += yyleng;}
endloop {printf("ENDLOOP\n"); col_num += yyleng;}
continue {printf("CONTINUE\n"); col_num += yyleng;}
break {printf("BREAK\n"); col_num += yyleng;}
read {printf("READ\n"); col_num += yyleng;}
write {printf("WRITE\n"); col_num += yyleng;}
not {printf("NOT\n"); col_num += yyleng;}
true {printf("TRUE\n"); col_num += yyleng;}
false {printf("FALSE\n"); col_num += yyleng;}
return {printf("RETURN\n"); col_num += yyleng;}

"-" {printf("SUB\n"); col_num += yyleng;}
"+" {printf("ADD\n"); col_num += yyleng;}
"*" {printf("MULT\n"); col_num += yyleng;}
"/" {printf("DIV\n"); col_num += yyleng;}
"%" {printf("MOD\n"); col_num += yyleng;}

"==" {printf("EQ\n"); col_num += yyleng;}
"<>" {printf("NEQ\n"); col_num += yyleng;}
"<" {printf("LT\n"); col_num += yyleng;}
">" {printf("GT\n"); col_num += yyleng;}
"<=" {printf("LTE\n"); col_num += yyleng;}
">=" {printf("GTE\n"); col_num += yyleng;}

{INTEGER} {printf("NUMBER %s\n", yytext); col_num += yyleng;}

[0-9_]{IDENTIFIER_SYMBOL}* {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", row_num, col_num, yytext); exit(1);}
{IDENTIFIER_SYMBOL}*_ {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", row_num, col_num, yytext); exit(1);}
{IDENTIFIER_SYMBOL}+ {printf("IDENT %s\n", yytext); col_num += yyleng;}

";" {printf("SEMICOLON\n"); col_num += yyleng;}
":" {printf("COLON\n"); col_num += yyleng;}
"," {printf("COMMA\n"); col_num += yyleng;}
"(" {printf("L_PAREN\n"); col_num += yyleng;}
")" {printf("R_PAREN\n"); col_num += yyleng;}
"[" {printf("L_SQUARE_BRACKET\n"); col_num += yyleng;}
"]" {printf("R_SQUARE_BRACKET\n"); col_num += yyleng;}
":=" {printf("ASSIGN\n"); col_num += yyleng;}


. {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", row_num, col_num, yytext); exit(1);}

%%

/* C functions used in lexer */

int main (int argc, char** argv) {
	yylex();
	return 0;
}