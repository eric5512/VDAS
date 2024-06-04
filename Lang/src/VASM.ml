type device_t = ADC0 | ADC1 
| CADC0 | CADC1
| DI0 | DI1 | DI2 | DI3 | DI4 | DI5 | DI6 | DI7
| DO0 | DO1 | DO2 | DO3 | DO4 | DO5 | DO6 | DO7
| DAC0 | DAC1;;

exception DeviceError of device_t * string;;

let is_input (dev: device_t): bool = match dev with
| ADC0 | ADC1 | CADC0 | CADC1
| DI0 | DI1 | DI2 | DI3 | DI4 | DI5 | DI6 | DI7 -> true
| DO0 | DO1 | DO2 | DO3 | DO4 | DO5 | DO6 | DO7
| DAC0 | DAC1 -> false;;

let is_digital (dev: device_t): bool = match dev with
| ADC0 | ADC1 | CADC0 | CADC1
| DAC0 | DAC1 -> false
| DO0 | DO1 | DO2 | DO3 | DO4 | DO5 | DO6 | DO7
| DI0 | DI1 | DI2 | DI3 | DI4 | DI5 | DI6 | DI7 -> true;;

let dev_of_string_opt (str: string): device_t Option.t =
  match str with
    | "DI0" -> Some DI0 
    | "DI1" -> Some DI1 
    | "DI2" -> Some DI2 
    | "DI3" -> Some DI3 
    | "DI4" -> Some DI4 
    | "DI5" -> Some DI5 
    | "DI6" -> Some DI6 
    | "DI7" -> Some DI7
    | "DO0" -> Some DO0 
    | "DO1" -> Some DO1 
    | "DO2" -> Some DO2 
    | "DO3" -> Some DO3 
    | "DO4" -> Some DO4 
    | "DO5" -> Some DO5 
    | "DO6" -> Some DO6 
    | "DO7" -> Some DO7
    | "ADC0" -> Some ADC0
    | "ADC1" -> Some ADC1
    | "CurrentADC0" -> Some CADC0
    | "CurrentADC1" -> Some CADC1
    | "DAC0" -> Some DAC0
    | "DAC1" -> Some DAC1
    | _ -> None;;

let dev_to_string (dev: device_t): string =
  match dev with
    | DI0 -> "DI0"  
    | DI1 -> "DI1"  
    | DI2 -> "DI2"  
    | DI3 -> "DI3"  
    | DI4 -> "DI4"  
    | DI5 -> "DI5"  
    | DI6 -> "DI6"  
    | DI7 -> "DI7" 
    | DO0 -> "DO0"  
    | DO1 -> "DO1"  
    | DO2 -> "DO2"  
    | DO3 -> "DO3"  
    | DO4 -> "DO4"  
    | DO5 -> "DO5"  
    | DO6 -> "DO6"  
    | DO7 -> "DO7" 
    | ADC0 -> "ADC0" 
    | ADC1 -> "ADC1" 
    | CADC0 -> "CADC0" 
    | CADC1 -> "CADC1" 
    | DAC0 -> "DAC0" 
    | DAC1 -> "DAC1";;

type devices_t = (string, device_t) Hashtbl.t;;

let dev_dict (ast: Util.program_t): devices_t =
  let dict = Hashtbl.create 10 in
  List.iter (fun elem -> match elem with
    | AST.Init (ty, s, _) -> (match dev_of_string_opt ty with
      | Some d -> Hashtbl.add dict s d
      | None -> ())
    | _ -> ()) ast;
  dict;;

let voltage_fs: float = 20.0;;

let activate (dev: device_t): bytes = (* 0b000DDDD0 *)
  let activate_size = 1 in
  let ret = Bytes.create activate_size in
  Bytes.set_int8 ret (match dev with
    | DI0 -> 0b00000000 
    | DI1 -> 0b00000010 
    | DI2 -> 0b00000100 
    | DI3 -> 0b00000110 
    | DI4 -> 0b00001000 
    | DI5 -> 0b00001010 
    | DI6 -> 0b00001100 
    | DI7 -> 0b00001110
    | ADC0 -> 0b00010000
    | ADC1 -> 0b00010010
    | CADC0 -> 0b00010100
    | CADC1 -> 0b00010110
    | _ -> raise (DeviceError (dev, "activate"))) 0;
  ret;;

let set_digital_python (dev: device_t) (value: string): string = 
  let dev_str = match dev with
    | DO0 -> "000"
    | DO1 -> "001"
    | DO2 -> "010"
    | DO3 -> "011"
    | DO4 -> "100"
    | DO5 -> "101"
    | DO6 -> "110"
    | DO7 -> "111"
    | _ -> raise (DeviceError (dev, "digital set")) in
  Printf.sprintf "(0b001%s &lt;&lt; 2 + 0b1 if %s else 0b0 &lt;&lt; 1).to_bytes(1, 'big')" dev_str value;;

let set_digital (dev: device_t) (value: bool): bytes = (* 0b001DDDV0 *)
  let set_digital_size = 1 in
  let ret = Bytes.create set_digital_size in
  Bytes.set_int8 ret ((match dev with
    | DO0 -> 0b00100000
    | DO1 -> 0b00100100
    | DO2 -> 0b00101000
    | DO3 -> 0b00101100
    | DO4 -> 0b00110000
    | DO5 -> 0b00110100
    | DO6 -> 0b00111000
    | DO7 -> 0b00111100
    | _ -> raise (DeviceError (dev, "digital set"))) lor (if value then 0b10 else 0b00) ) 0;
  ret;;

let set_analog_python (dev: device_t) (value: string): string = 
  let dev_str = match dev with
    | DAC0 -> "0"
    | DAC1 -> "1"
    | _ -> raise (DeviceError (dev, "analog set")) in
  Printf.sprintf "(0b010%s &lt;&lt; 12 + (int((%s+10)/20) &#38; 0b111111111111)).to_bytes(2, 'big')" dev_str value;;

let set_analog (dev: device_t) (fvalue: float): bytes = (* 0b010DNNNN NNNNNNNN *)
  let set_analog_size = 2 in
  let value = (fvalue /. voltage_fs +. 0.5) *. (float_of_int 0b111111111111) |> int_of_float in
  let hi_val = (value land 0b111100000000) lsr 7 in
  let lo_val = (value land 0b11111111) lsl 1 in
  let dev_val = (match dev with
    | DAC0 -> 0b01000000
    | DAC1 -> 0b01010000
    | _ -> raise (DeviceError (dev, "analog set"))) in
  let ret = Bytes.create set_analog_size in
  Bytes.set_uint8 ret 0 (dev_val lor hi_val);
  Bytes.set_uint8 ret 1 (lo_val);
  ret;;

let set_AWG (dev: device_t) (pre: int) (size: int) (values: int list): bytes = (* 0b011PPPPS SSSSSSSS S... *)
  (* let bit_size = (float_of_int (size * 8 + 3 + 4 + 12)) /. 8.0 |> ceil in *)
  failwith "Not implemented";;