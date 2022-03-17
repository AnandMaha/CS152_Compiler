/* cs152-miniL phase3 */

%{
  #include <stdio.h>
#include <stdlib.h>
#include<string>
#include<vector>
#include<string.h>
#include<fstream>
#include<sstream>
#include<iostream>
#include <stack>

  using namespace std;
void yyerror(const char *msg);
extern int yylex();
#include "lib.h"

bool is_main_defined = 0;
bool has_found_error = 0;

stack<string> expression_stck,identifier_stck,
parameter_stck,label_stck; 
  
stringstream out;
ostringstream out_flush;

string gen_temp() {
  static int count = 0;
  return "__temp__" + to_string(count++);
}

string gen_label() {
  static int count_2 = 0;
  return "__label__" + to_string(count_2++);
}

int param_cnt = 0;

enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}
void check_valid_identifier(char* name){
  if(!find(name)){
    string err = "Undeclared IDENTIFIER: " + string(name);
    yyerror(err.c_str());
  }
}

%}

%union {
    int ival;
    char *sval;
    struct ProdNode {
      char name[255];
      int num;
      char index[255];
      int type; // 0 for integer, 1 for int array
    } node;
}

%error-verbose
%locations

%start Program

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP 
    CONTINUE BREAK READ WRITE TRUE FALSE RETURN 

%left SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET OR AND
%right NOT ASSIGN

%token <sval> IDENTIFIER 
%type <sval> Comp 

%token <ival> NUMBER

%type <node> Var Expression Term Multiplicative_Expr Declaration Statement Bool-Exp Statements

%token SEMICOLON COLON COMMA

%%

Program: Functions {printf("Program -> Functions\n"); if(!is_main_defined) { yyerror("No main function defined."); } }

Functions: Function Functions {printf("Functions -> Function Functions\n");} 
            | /*Epsilon*/{printf("Functions -> Epsilon \n");}

Function: FUNCTION IDENTIFIER
{
  // midrule:
  // add the function to the symbol table.
  string func_name = $2;
  add_function_to_symbol_table(func_name);
  if(string($2) == "main") /* to ensure a main is defined */
    is_main_defined = 1;
  out << "func " << func_name << endl;
}
 SEMICOLON BEGIN_PARAMS Declarations
 {
   while (!parameter_stck.empty()){
      out << "= " << parameter_stck.top() << ", " << "$" << param_cnt++ << endl;
      parameter_stck.pop();
    }
 } 
 END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY
{
  printf("Function -> FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS Declarations END_LOCALS BEGIN_BODY Statements END_BODY\n");
  while (!parameter_stck.empty()) 
    parameter_stck.pop();
  param_cnt = 0;
  out_flush << "endfunc" << endl;
}

Declarations: Declaration SEMICOLON Declarations {printf("Declarations -> Declaration SEMICOLON Declarations\n");}
                | /*Epsilon*/ {printf("Declarations -> Epsilon \n");}

Declaration: IDENTIFIER COLON INTEGER 
{
  printf("Declaration -> IDENTIFIER COLON INTEGER\n");
  
  if(find($1)){
    string temp = $1;
    string err = "symbol \"" + temp + "\" is multiply-defined";
    yyerror(err.c_str());
  }

  identifier_stck.push($1);
  parameter_stck.push($1);
  while(!identifier_stck.empty()) {
    string temp = identifier_stck.top();
    // add the variable to the symbol table.
    std::string value = $1;
    Type t = Integer;
    add_variable_to_symbol_table(value, t);
    out << ". " << temp << endl;
    identifier_stck.pop(); 
  }
}
| IDENTIFIER COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
{
  printf("Declaration -> IDENTIFIER COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER \n");
  
  if(find($1)){
    string temp = $1;
    string err = "symbol \"" + temp + "\" is multiply-defined";
    yyerror(err.c_str());
  }

  identifier_stck.push($1);
  parameter_stck.push($1);
  while(!identifier_stck.empty()) {
    string temp = identifier_stck.top();
    // add the variable to the symbol table.
    std::string value = $1;
    Type t = Array;
    add_variable_to_symbol_table(value, t);
    out << ".[] " << temp << ", " << $5 << endl;
    identifier_stck.pop(); 
  }
}

Statements: Statement SEMICOLON Statements {printf("Statements -> Statement SEMICOLON Statements\n");}
                | /*Epsilon*/ {printf("Statements -> Epsilon\n");}

Statement: Var ASSIGN Expression 
{
  printf("Statement -> Var ASSIGN Expression\n");

  if($1.type == 0) {
    out << "= " << $1.name << ", " << $3.name << endl;
  } else if($1.type == 1) {
    out << "[]= " << $1.name << ", " << $1.index << ", " << $3.name << endl;
  }
  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}
| IF Bool-Exp THEN
{
  string a = gen_label();
  string b = gen_label();
  label_stck.push(b); 
  out << "?:= " << a << ", " << $2.name << endl;
  out << ":= " << b << endl;
  out << ": " << a << endl;
} 
Statement SEMICOLON Statements Else ENDIF 
{
  printf("Statement -> IF Bool-Exp THEN Statements ENDIF\n");
  
  if(label_stck.size() > 0){
    out << ": " << label_stck.top() << endl;
    label_stck.pop();
    out_flush << out.rdbuf();
    out.clear();
    out.str(" ");
  }
}
| WHILE Bool-Exp BEGINLOOP 
{
  printf("Statement -> WHILE Bool-Exp BEGINLOOP Statements ENDLOOP\n");

  string a = gen_label();
  string b = gen_label();
  string c = gen_label();
  out_flush << ": " << c << endl;

  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");

  out << "?:= " << a << ", " << const_cast<char*>($2.name) << endl;
  out << ":= " << b << endl;
  out << ": " << a << endl;

  label_stck.push(c);
  label_stck.push(b);
} 
Statement SEMICOLON Statements ENDLOOP 
{
    out_flush << out.rdbuf();
    out.clear();
    out.str(" ");
    if(label_stck.size() > 1){
      string b = label_stck.top();
      label_stck.pop();
      string c = label_stck.top();
      label_stck.pop();
      out << ":= " << c << endl;
       out << ": " << b << endl;
    }

    out_flush << out.rdbuf();
    out.clear();
    out.str(" ");
}
| DO BEGINLOOP 
{
  string a = gen_label();
  label_stck.push(a);
  out_flush << ": " << a << endl;
  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}
Statement SEMICOLON Statements ENDLOOP WHILE Bool-Exp 
{
  printf("Statement -> DO BEGINLOOP Statements ENDLOOP WHILE Bool-Exp\n");
  if(!label_stck.empty()){
    string a = label_stck.top();
    out << "?:= " << a << ", "  << $9.name  << endl;
    label_stck.pop(); 
  }
  
  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}
| READ Var 
{
  printf("Statement -> READ Var\n");
  
  if ($2.type == 0) {
    out << ".< " << $2.name << endl;
  } else if ($2.type == 1) {
    out << ".[]< " << $2.name << ", "  << $2.index << endl;
  }

  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}
| WRITE Var 
{
  printf("Statement -> WRITE Var\n");
  
  if ($2.type == 0) {
    out << ".> " << $2.name << endl;
  } else if ($2.type == 1) {
    out << ".[]> " << $2.name << ", "  << $2.index << endl;
  }

  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}
| CONTINUE {
  printf("Statement -> CONTINUE\n");
  
  if(!label_stck.empty()) {
    out << ":= " << label_stck.top() << endl;
    out_flush << out.rdbuf();
    out.clear();
    out.str(" ");
  } else {
    yyerror("\'continue\' used outside of loop");
  }
}
| BREAK {
  printf("Statement -> BREAK\n");
  
  if(!label_stck.empty()) {
    stack<string> temp_stck;
    while(label_stck.size() > 2) {
        temp_stck.push(label_stck.top());
        label_stck.pop();
    }
    // if breaking, must jump to outermost 
      out << ":= " << label_stck.top() << endl;
      out_flush << out.rdbuf();
      out.clear();
      out.str(" ");
    while(temp_stck.size() > 0) {
        label_stck.push(temp_stck.top());
        temp_stck.pop();
    }
    
  } else {
    yyerror("\'break\' used outside of loop");
  }
}
| RETURN Expression 
{
  printf("Statement -> RETURN Expression\n");
  
  $$.num = $2.num;
  strcpy($$.name,$2.name);
  out << "ret " << $2.name << endl;

  out_flush << out.rdbuf();
  out.clear();
  out.str(" ");
}

Else: /*Epsilon*/ {printf("Else -> /*Epsilon*/\n");}
| ELSE {
  if(!label_stck.empty()){
    string label = gen_label(); 
    out << ":= " << label << endl;
    out << ": " << label_stck.top() << endl;
    label_stck.pop();
    label_stck.push(label);
  }
} 
Statement SEMICOLON Statements 
{printf("Else -> ELSE Statement SEMICOLON Statements \n");}

Var: IDENTIFIER 
{
  printf("Var -> IDENTIFIER\n");

  check_valid_identifier($1);
  strcpy($$.name,$1);
  $$.type = 0;
}
| IDENTIFIER L_SQUARE_BRACKET Expression R_SQUARE_BRACKET 
{
  printf("Var -> IDENTIFIER L_SQUARE_BRACKET Expression R_PAREN\n");
  
  check_valid_identifier($1);
  
  if ($3.type == 0) {
    strcpy($$.name, $1);
    strcpy($$.index, $3.name);
    $$.type = 1;
  }
  else {
    string temp = gen_temp();
    strcpy($$.name, $1);
    strcpy($$.index, temp.c_str());
    $$.type = 1;

    out << ". " << temp << endl; 
    out << "=[] " << temp << ", " << $3.name << ", " << $3.index << endl;
  }
}

Expression: Expression ADD Multiplicative_Expr  
{
  printf("Expression: Expression ADD Multiplicative_Expr\n");

  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "+ " << temp << ", " << const_cast<char*>($1.name) << ", " << const_cast<char*>($3.name) << endl;
  
  strcpy($$.name,temp.c_str());
}
| Expression SUB Multiplicative_Expr
{
  printf("Expression: Expression SUB Multiplicative_Expr\n");

  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "- " << temp << ", " << $1.name << ", " << $3.name << endl;
  strcpy($$.name,temp.c_str());
}
| Multiplicative_Expr
{
  printf("Expression: Multiplicative_Expr\n");

  strcpy($$.name, $1.name);
  $$.type = $1.type;
}

Multiplicative_Expr: Multiplicative_Expr MULT Term 
{
  printf("Multiplicative_Expr: Multiplicative_Expr MULT Term\n");
  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "* " << temp << ", " << $1.name << ", " << $3.name << endl;
  strcpy($$.name,temp.c_str());
} 
| Multiplicative_Expr DIV Term 
{
  printf("Multiplicative_Expr: Multiplicative_Expr DIV Term\n");
  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "/ " << temp << ", " << $1.name << ", " << $3.name << endl;
  strcpy($$.name,temp.c_str());
}
| Multiplicative_Expr MOD Term 
{
  printf("Multiplicative_Expr: Multiplicative_Expr MOD Term\n");
  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "% " << temp << ", " << $1.name << ", " << $3.name << endl;
  strcpy($$.name, temp.c_str());
}  
| Term
{
  printf("Multiplicative_Expr: Term\n");
  strcpy($$.name, $1.name);
  $$.type = $1.type;
} 

Term: Var 
{
  printf("Term -> Var\n");

  $$.type = $1.type;
  $$.num = $1.num;
  strcpy($$.name,gen_temp().c_str());
  strcpy($$.index,$$.name);
  out << ". " << $$.name << endl;
  if($1.type == 0){
    out << "= " << $$.name << ", " << $1.name << endl;
  } else if($1.type == 1){
    out << "=[] " << $$.name << ", " << $1.name << ", " << $1.index << endl;
  }
} 
| NUMBER 
{
  printf("Term -> NUMBER\n");
  
  $$.num = $1;
  $$.type = 0;
  strcpy($$.index,$$.name);
  strcpy($$.name,gen_temp().c_str());
  out << ". " << $$.name << endl;
  out << "= " << $$.name << ", " << $$.num << endl;
} 
| L_PAREN Expression R_PAREN 
{
  printf("Term -> L_PAREN Expression R_PAREN\n");

  strcpy($$.name, $2.name);  
} 
| IDENTIFIER L_PAREN Expression Comma_Expr R_PAREN 
{
  printf("Term -> IDENTIFIER L_PAREN Expression Comma_Expr R_PAREN\n");
  
  expression_stck.push($3.name); 
  while (!expression_stck.empty()){
    out << "param " << expression_stck.top() << endl;
    expression_stck.pop();
  }
  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "call " << $1 << ", " << temp << endl;
  strcpy($$.name,temp.c_str());
} 
| IDENTIFIER L_PAREN R_PAREN {
  printf("Term -> IDENT L_PAREN R_PAREN\n");

  string temp = gen_temp();
  out << ". " << temp << endl;
  out << "call " << $1 << ", " << temp << endl;
  strcpy($$.name,temp.c_str());
}

Comma_Expr: COMMA Expression Comma_Expr
{
  printf("Comma_Expr -> COMMA Expression\n");
  expression_stck.push($2.name);
} 
| /*Epsilon*/ {printf("Comma_Expr -> Epsilon\n");}

Bool-Exp: NOT Bool-Exp
{
  printf("Bool-Exp -> NOT Bool-Exp\n");

  string temp = gen_temp();
  strcpy($$.name, temp.c_str());
  out << ". " << temp << endl;
  out << "! " << temp << ", " << $2.name << endl;
}
| Expression Comp Expression 
{
  printf("Bool-Exp -> Expression Comp Expression\n");

  string temp = gen_temp();
  strcpy($$.name, temp.c_str());
  out << ". " << temp << endl;
  out << $2 << " " << temp << ", " << $1.name << ", " << $3.name << endl;
}

Comp: EQ {printf("Comp -> EQ\n"); $$ = const_cast<char*>("==");}
        | NEQ {printf("Comp -> NEQ\n");$$ = const_cast<char*>("!=");}
        | LT {printf("Comp -> LT\n");$$ = const_cast<char*>("<");}
        | GT {printf("Comp -> GT\n");$$ = const_cast<char*>(">");}
        | LTE {printf("Comp -> LTE\n");$$ = const_cast<char*>("<=");}
        | GTE {printf("Comp -> GTE\n");$$ = const_cast<char*>(">=");}

%%

int main(int argc, char **argv) {
   yyparse();
   if(!has_found_error){
    ofstream file_output("test.mil");
    file_output << out_flush.str() << endl;
    file_output.close();
    cout << out_flush.str() << endl;
   }
   return 0;
}

void yyerror(const char *msg) {
    extern int row_num, col_num;
    has_found_error = 1;
    printf("** Line %d Column %d: %s\n", row_num, col_num, msg);
}