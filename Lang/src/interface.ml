let string_of_indev (dev: VASM.device_t): string = match dev with
  | DI0 -> "self.DI[0]"
  | DI1 -> "self.DI[1]"
  | DI2 -> "self.DI[2]"
  | DI3 -> "self.DI[3]"
  | DI4 -> "self.DI[4]"
  | DI5 -> "self.DI[5]"
  | DI6 -> "self.DI[6]"
  | DI7 -> "self.DI[7]"
  | ADC0 -> "self.ADC[0]"
  | ADC1 -> "self.ADC[1]"
  | CADC0 -> "self.CADC[0]"
  | CADC1 -> "self.CADC[1]"
  | _ -> raise (VASM.DeviceError (dev, "string of input device"));;

let string_of_component (comp: AST.comp_t): string = match comp with
  | Left l -> Printf.sprintf "self.all[\"%s\"]" l
  | Right (n, v) -> Printf.sprintf "self.all[\"%s\"][\"%s\"]" n v;;

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