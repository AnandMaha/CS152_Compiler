    /* cs152-miniL phase2 */
%code requires{  
#include <stdio.h>
#include <stdlib.h>
}

%{
void yyerror(const char *msg);
%}

%union {
    int ival;
    char *sval;
}

%error-verbose
%locations

%start Program

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP 
    CONTINUE BREAK READ WRITE NOT TRUE FALSE RETURN 

%left SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE

%token <sval> IDENTIFIER

%token <ival> NUMBER

%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN

%%

Program: Functions {printf("Program -> Functions\n");}

Functions: Function Functions {printf("Functions -> Function Functions\n");} 
            | /*Epsilon*/{printf("Functions -> Epsilon \n");}

Function: FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS Declarations END_PARAMS 
            BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
            {printf("Function -> FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY\n");}

Declarations: Declaration SEMICOLON Declarations {printf("Declarations -> Declaration SEMICOLON Declarations\n");}
                | /*Epsilon*/ {printf("Declarations -> Epsilon \n");}

Declaration: IDENTIFIER COLON Array INTEGER {printf("Declaration -> IDENTIFIER COLON Array INTEGER\n");}

Array: ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF {printf("Array -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF\n");}
        | /*Epsilon*/{printf("Array -> Epsilon \n");}

Statements: Statement SEMICOLON Statements {printf("Statements -> Statement SEMICOLON Statements\n");}
                | /*Epsilon*/ {printf("Statements -> Epsilon\n");}

Statement: Var ASSIGN Expression {printf("Statement -> Var ASSIGN Expression\n");}
            | IF Bool-Exp THEN Statements ENDIF {printf("Statement -> IF Bool-Exp THEN Statements ENDIF\n");}
            | IF Bool-Exp THEN Statements ELSE Statements ENDIF {printf("Statement -> IF Bool-Exp THEN Statements ELSE Statements ENDIF\n");}
            | WHILE Bool-Exp BEGINLOOP Statements ENDLOOP {printf("Statement -> WHILE Bool-Exp BEGINLOOP Statements ENDLOOP\n");}
            | DO BEGINLOOP Statements ENDLOOP WHILE Bool-Exp {printf("Statement -> DO BEGINLOOP Statements ENDLOOP WHILE Bool-Exp\n");}
            | READ Var {printf("Statement -> READ Var\n");}
            | WRITE Var {printf("Statement -> WRITE Var\n");}
            | CONTINUE {printf("Statement -> CONTINUE\n");}
            | BREAK {printf("Statement -> BREAK\n");}
            | RETURN Expression {printf("Statement -> RETURN Expression\n");}

Var: IDENTIFIER {printf("Var -> IDENTIFIER\n");}
        | IDENTIFIER L_SQUARE_BRACKET Expression R_PAREN {printf("Var -> IDENTIFIER L_SQUARE_BRACKET Expression R_PAREN\n");}

Expression: Multiplicative_Expr Addop_Expr  {printf("Expression -> Multiplicative_Expr Addop_Expr\n");}

Multiplicative_Expr: Term Multop_Term {printf("Multiplicative_Expr -> Term Multop_Term\n");} 

Term: Var {printf("Term -> Var\n");} 
        | NUMBER {printf("Term -> NUMBER\n");} 
        | L_PAREN Expression R_PAREN {printf("Term -> L_PAREN Expression R_PAREN\n");} 
        | IDENTIFIER L_PAREN Expression Comma_Expr R_PAREN {printf("IDENTIFIER L_PAREN Expression Comma_Expr R_PAREN\n");} 

Comma_Expr: COMMA Expression {printf("Comma_Expr -> COMMA Expression\n");} 
            | /*Epsilon*/ {printf("Comma_Expr -> Epsilon\n");}

Multop_Term: MULT Term {printf("Multop_Term -> MULT Term\n");} 
                | DIV Term {printf("Multop_Term -> DIV Term\n");} 
                | MOD Term {printf("Multop_Term -> MOD Term\n");} 
                | /*Epsilon*/ {printf("Multop_Term -> Epsilon\n");}

Addop_Expr: ADD Multiplicative_Expr Addop_Expr {printf("Addop_Expr -> ADD Multiplicative_Expr\n");} 
            | SUB Multiplicative_Expr Addop_Expr {printf("Addop_Expr -> SUB Multiplicative_Expr\n");} 
            | /*Epsilon*/ {printf("Addop_Expr -> Epsilon\n");} 

Bool-Exp: Nots Expression Comp Expression {printf("Bool-Exp -> Nots Expression Comp Expression\n");}

Nots: NOT Nots {printf("Nots -> NOT Nots\n");} 
        | /*Epsilon*/ {printf("Nots -> Epsilon\n");}

Comp: EQ {printf("Comp -> EQ\n");}
        | NEQ {printf("Comp -> EQ\n");}
        | LT {printf("Comp -> LT\n");}
        | GT {printf("Comp -> GT\n");}
        | LTE {printf("Comp -> LTE\n");}
        | GTE {printf("Comp -> GTE\n");}

%%

int main(int argc, char **argv) {
   yyparse();
   return 0;
}

void yyerror(const char *msg) {
    extern int row_num, col_num;
    printf("** Line %d Column %d: %s\n", row_num, col_num, msg);
}