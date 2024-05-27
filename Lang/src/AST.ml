type comp_t = (string, (string * string)) Either.t

type bop_t = Add | Sub | Mul | Div | Pow

type expr_t = Op of bop_t * expr_t * expr_t |
              Comp of comp_t |
              Const of float

type ins_t = Init of (string * string * ((string * string) list)) | (* type, name, arguments *)
              Def of (string * float) | (* name, value *)
              Link of (expr_t * comp_t)