let string_of_indev (dev: VASM.device_t): string = match dev with
  | DI0 -> "self.DI0"
  | DI1 -> "self.DI1"
  | DI2 -> "self.DI2"
  | DI3 -> "self.DI3"
  | DI4 -> "self.DI4"
  | DI5 -> "self.DI5"
  | DI6 -> "self.DI6"
  | DI7 -> "self.DI7"
  | ADC0 -> "self.ADC0"
  | ADC1 -> "self.ADC1"
  | CADC0 -> "self.CADC0"
  | CADC1 -> "self.CADC1"
  | _ -> raise (VASM.DeviceError (dev, "string of input device"));;

let string_of_component (comp: AST.comp_t): string = match comp with
  | Left l -> Printf.sprintf "self.find(\"%s\")" l
  | Right (n, v) -> failwith "Component attributes not implemented";;

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
    | Const f -> Printf.sprintf "%f" f;;