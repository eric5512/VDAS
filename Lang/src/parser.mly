%{
open AST
%}

%token <float> NUM
%token <string> ID
%token <string> STR
%token ARR COL EQ
%token LPAR RPAR COMMA
%token EOL

%token DEF

%token ADD SUB MUL DIV POW

%left ADD SUB
%left MUL DIV
%right POW

%start <ins_t> main

%%

main:
| i = instruction EOL
    { i }

instruction:
| DEF n = ID v = NUM
    { Def (n, v)}
| e = expr ARR c = component
    { Link (e, c)}
| t = ID n = ID LPAR argsl = separated_list(COMMA, args) RPAR
    { Init (t, n, argsl) }

args:
| n = ID EQ v = STR
    { (n, v) }

expr:
| v = NUM
    { Const v }
| c = component
    { Comp c }
| o = operation
    { o }

component:
| n = ID
    { (Left n) }
| n = ID COL a = ID
    { failwith "Properties not implemented yet"; (Right (n, a)) }

operation:
| LPAR o = operation RPAR
    { o }
| e1 = expr ADD e2 = expr
    { Op (Add, e1, e2) }
| e1 = expr SUB e2 = expr
    { Op (Sub, e1, e2) }
| SUB e = expr
    { Op (Sub, Const 0.0, e) }
| e1 = expr MUL e2 = expr
    { Op (Mul, e1, e2) }
| e1 = expr DIV e2 = expr
    { Op (Div, e1, e2) }
| e1 = expr POW e2 = expr
    { Op (Pow, e1, e2) }