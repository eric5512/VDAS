type program_t = AST.ins_t list;;

let process (line : string) (line_num: int): (AST.ins_t, string) Either.t =
  let linebuf = Lexing.from_string (line) in
  try
    Left (Parser.main Lexer.token linebuf)
  with
  | Lexer.Error msg ->
    Right ((Format.sprintf "Line %d%!, " line_num) ^ msg)
  | Parser.Error ->
    Right (Format.sprintf "Line %d, At offset %d: syntax error.\n%!" line_num (Lexing.lexeme_start linebuf))
  | e ->
    Right (Printexc.to_string e^"\n");;

let process (lines : string list): (program_t * string list) =
  let rec aux ins errs count = function
  | h::t -> if String.for_all (fun c -> c = ' ' || c = '\n' || c = '\r') h then aux ins errs (count + 1) t else (match process h count with
    | Left i -> aux (i::ins) errs (count + 1) t
    | Right e -> aux ins (e::errs) (count + 1) t)
  | _ -> (ins, List.rev errs) in
  aux [] [] 1 lines;;

let process_AST (ast: program_t): program_t =
  let sub_constants (ast: program_t): program_t = 
    let hashtbl_const (ast: program_t): (string, float) Hashtbl.t = 
      let table = Hashtbl.create 10 in
      let aux = function
        | AST.Def (n, v) -> Hashtbl.add table n v
        | _ -> () in
      List.iter aux ast; table in
    let table = hashtbl_const ast in
    let sub_element (ins: AST.ins_t): AST.ins_t = 
      let rec sub_expr (expr: AST.expr_t): AST.expr_t = 
        match expr with
        | Op (bop, ex1, ex2) -> Op (bop, sub_expr ex1, sub_expr ex2)
        | Comp (Left n) as o -> (match Hashtbl.find_opt table n with
          | Some v -> Const v
          | None -> o) 
        | e -> e in
      match ins with
        | Link (e, c) -> Link (sub_expr e, c)
        | e -> e in
    List.map sub_element ast in

  let components_exist (ast: program_t): program_t = Fun.id ast in
  sub_constants ast |> components_exist;;

let rec get_lines (channel : Lexing.lexbuf): string list =
  let optional_line, continue = Lexer.line channel in
  match optional_line with
  | None -> if continue then get_lines channel else []
  | Some l -> if continue then l::(get_lines channel) else [l];;

let rec find_args_def (args: (string * string) list) (arg: string) (default: string): string = 
  match args with
  | (name, value)::t -> if name = arg then value else find_args_def t arg default
  | [] -> default;;

let string_of_component (comp: AST.comp_t): string = match comp with
  | Left l -> l
  | Right (n, v) -> Printf.sprintf "%s:%s" n v;;
  
let rec string_of_expression (expr: AST.expr_t): string = 
  let bop_to_str (bop: AST.bop_t): string =
    match bop with
      | Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"
      | Pow -> "^" in
  match expr with 
    | Op (bop, ex1, ex2) -> "(" ^ string_of_expression ex1 ^ bop_to_str bop ^ string_of_expression ex2 ^ ")"
    | Comp c -> string_of_component c 
    | Const f -> string_of_float f;;

let print_instruction (instruction: AST.ins_t): unit = 
  let print_component (component: AST.comp_t): unit =
    string_of_component component |> print_string in
  let rec print_expression (expression: AST.expr_t): unit = 
    string_of_expression expression |> print_string in
  match instruction with
    | Init (ty, name, args) -> let argss = List.fold_left (fun s1 (n, v) -> n ^ "=" ^ "\"" ^ v ^ "\"" ^ "," ^ s1) "" args in Printf.printf "Init (%s, %s, %s)\n" ty name argss
    | Def (n,v) -> Printf.printf "Def (%s, %f)\n" n v
    | Link (e, c) -> print_expression e; print_string " -> "; print_component c; print_char '\n';;
  