{
  open Parser

  exception Error of string

}

rule line = parse
| ([^'\n']* '\n') as line
    { Some line, true }
| eof
    { None, false }
| ([^'\n']+ as line) eof
    { Some (line ^ "\n"), false }
and token = parse
| [' ' '\t']
    { token lexbuf }
| '\n'
    { EOL }
| "\r\n"
    { EOL }
| "define"
    { DEF }
| ['0'-'9']+ '.'? ['0'-'9']* as f
    { NUM (float_of_string f) }
| ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '_' '0'-'9']* as s 
    { ID s }
| "->"
    { ARR }
| ','
    { COMMA }
| '='
    { EQ }
| '"'
    { read_string (Buffer.create 17) lexbuf }
| '+'
    { ADD }
| '-'
    { SUB }
| '^'
    { POW }
| '*'
    { MUL }
| '/'
    { DIV }
| '('
    { LPAR }
| ')'
    { RPAR }
| ':'
    { COL }
| _
    { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }
and read_string buf =
  parse
  | '"'       { STR (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (Error ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (Error ("String not terminated")) }