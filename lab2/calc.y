/* calculator. */

%code requires{  }

%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *msg);

%}

%union{
  int ival;
  float fval;
  char* sval;
  /* other types of definition */
}

%error-verbose
%locations

%start expr
%left '+' '-' '*' '/'
%type <ival> addop multop
%token <ival> INTEGER
%token <ival> EQ
%token <fval> DECIMAL
%token <sval> SCIENTIFICNUMBER
%% 

expr: term eq {printf("expr: term eq\n");}

eq: EQ {printf("eq: EQ\n");}

term: term addop term {printf("term: term addop term\n");} | term_2 { printf("term: term_2\n");}

addop: '+' | '-' {printf("addop: '+' | '-'\n");}

term_2: term_2 multop term_2 {printf("term_2: term_2 multop term_2\n");} | term_3 {printf("term_2: term_3\n");}

multop: '*' {printf("multop: '*'\n");} | '/' {printf("multop:'/'\n");}

term_3: 
   '-' '(' term ')' {printf("term_3: addop term_3\n");} 
   | '(' term ')' {printf("term_3: (term)\n");} 
   | INTEGER{printf("term_3: INTEGER \n");} 
   | '-' INTEGER{printf("term_3: '-' INTEGER \n");} 
   | DECIMAL{printf("term_3: DECIMAL \n");} 
   | SCIENTIFICNUMBER {printf("term_3: SCIENTIFICNUMBER\n");}

%% 

int main(int argc, char **argv) {
   yyparse();
   printVals();
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d: %s\n", yylloc.first_line, msg);
}