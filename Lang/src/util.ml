let process (line : string): AST.ins_t =
  let linebuf = Lexing.from_string line in
  Parser.main Lexer.token linebuf;;

let process (lines : string list): AST.ins_t list =
  List.map process lines;;

let rec get_lines (channel : Lexing.lexbuf): string list =
  let optional_line, continue = Lexer.line channel in
  match optional_line with
  | None -> if continue then get_lines channel else []
  | Some l -> if continue then l::(get_lines channel) else [l];;
