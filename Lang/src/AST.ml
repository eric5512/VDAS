type num_t = (string, float) Either.t

type comp_t = (string, (string * string)) Either.t

type expr_t = Op of string * num_t * num_t |
              Comp of comp_t

type ins_t = Init of (string * string * (string list)) | 
              Def of (string * float) |
              Link of (expr_t * comp_t)
