   /* cs152-calculator */
   
%{   
   int integer_cnt = 0; int dmcl_cnt = 0; int scf_cnt = 0; int operator_cnt = 0; int paren_cnt = 0; int equal_cnt = 0;
%}


   /* some common rules, for example DIGIT */
INTEGER    [0-9]+

DECIMAL  {INTEGER}?\.{INTEGER}  
SCIENTIFICNUMBER  ({INTEGER}|{DECIMAL})[Ee][+-]?{INTEGER}


%%
   /* specific lexer rules in regex */

"="            {printf("EQUAL\n"); equal_cnt++; }
"+"            {printf("PLUS\n"); operator_cnt++;}
"-"            {printf("MINUS\n"); operator_cnt++;}
"*"            {printf("MULT\n"); operator_cnt++;}
"/"            {printf("DIV\n"); operator_cnt++;}
"("            {printf("L_PAREN\n"); paren_cnt++;}
")"            {printf("R_PAREN\n"); paren_cnt++;}
{INTEGER}      {printf("NUMBER %s\n", yytext); integer_cnt++;}
{DECIMAL}   {printf("DECIMAL %s\n", yytext); dmcl_cnt++;} 
{SCIENTIFICNUMBER}   {printf("SCIENTIFIC %s\n", yytext); scf_cnt++;}

. {printf("Error\n"); exit(1);}

%%
	/* C functions used in lexer */

void printVals(){
   printf("NUM INTS: %d\nNUM DECIMALS: %d\nNUM SCIENTIFIC NUMBERS: %d\nNUM OPERATOR: %d\nNUM PARENTHESES: %d\nNUM EQUAL: %d\n", integer_cnt, dmcl_cnt, scf_cnt, operator_cnt, paren_cnt, equal_cnt);
}

int main(int argc, char ** argv)
{
   yylex();
   printVals();;
}


