%{
open AST
%}

%token <float> NUM
%token <string> ID
%token OP
%token LPAR RPAR COMMA
%token EOL

%token ASSIGN DEF

%left ADD SUB
%left MUL DIV
%left POW

%start <ins_t> main

%%

main:
| i = instruction EOL
    { i }

instruction:
| 

link:
|

expression:
| ID

(*
expression:
| o = operation
    { Op o }
| DEF fn = ID LPAR vars = separated_nonempty_list(COMMA, ID) RPAR ASSIGN o = operation
    { FunDef (fn, vars, o) }
| DEF var = ID ASSIGN o = operation
    { VarDef (var, o) }

operation:
| i = NUM
    { Val i }
| s = ID LPAR e = separated_nonempty_list(COMMA, operation) RPAR
    { Fun(s, Array.of_list e) }
| LPAR e = operation RPAR
    { e }
| e1 = operation ADD e2 = operation
    { Bop (Add, e1, e2) }
| e1 = operation SUB e2 = operation
    { Bop (Sub, e1, e2) }
| SUB e = operation
    { Neg e }
| e1 = operation MUL e2 = operation
    { Bop (Mul, e1, e2) }
| e1 = operation DIV e2 = operation
    { Bop (Div, e1, e2) }
| e1 = operation POW e2 = operation
    { Bop (Pow, e1, e2) }
| s = ID
    { Var s }
*)