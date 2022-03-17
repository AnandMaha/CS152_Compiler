   /* cs152-calculator */
   
%{  
   #include "parser.h"

   int integer_cnt = 0; int dmcl_cnt = 0; int scf_cnt = 0; int operator_cnt = 0; int paren_cnt = 0; int equal_cnt = 0;
%}


   /* some common rules, for example DIGIT */
INTEGER    [0-9]+

DECIMAL  {INTEGER}?\.{INTEGER}  
SCIENTIFICNUMBER  ({INTEGER}|{DECIMAL})[Ee][+-]?{INTEGER}


%%
   /* specific lexer rules in regex */

"="            {printf("EQUAL\n"); equal_cnt++; yylval.ival = atoi(yytext); return EQ; }
"+"            {printf("PLUS\n"); operator_cnt++; return '+';}
"-"            {printf("MINUS\n"); operator_cnt++; return '-';}
"*"            {printf("MULT\n"); operator_cnt++; return '*';}
"/"            {printf("DIV\n"); operator_cnt++; return '/';}
"("            {printf("L_PAREN\n"); paren_cnt++; return '(';}
")"            {printf("R_PAREN\n"); paren_cnt++; return ')';}
{INTEGER}      {printf("NUMBER %s\n", yytext); integer_cnt++; yylval.ival = atoi(yytext); return INTEGER;}
{DECIMAL}   {printf("DECIMAL %s\n", yytext); dmcl_cnt++;yylval.ival = atof(yytext); return DECIMAL;} 
{SCIENTIFICNUMBER}   {printf("SCIENTIFIC %s\n", yytext); scf_cnt++;yylval.sval = yytext; return SCIENTIFICNUMBER;}

. {printf("Error: UNABLE TO MATCH TOKEN. \n"); exit(1);}

%%
	/* C functions used in lexer */

void printVals(){
   printf("NUM INTS: %d\nNUM DECIMALS: %d\nNUM SCIENTIFIC NUMBERS: %d\nNUM OPERATOR: %d\nNUM PARENTHESES: %d\nNUM EQUAL: %d\n", integer_cnt, dmcl_cnt, scf_cnt, operator_cnt, paren_cnt, equal_cnt);
}

