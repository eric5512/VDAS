exception DataSource of string;;
exception InexistentType of string;;

let get_AST (path: string): Util.program_t = 
  let (ins, errs) = Util.get_lines (open_in path |> Lexing.from_channel) |> Util.process in
  if errs = [] then ins else failwith (List.hd errs);;

let get_widgets (ast: Util.program_t): string list = 
  (* let (win_h, win_w) = Ui.size_window in *)
  let pad = 20 in
  let x = ref pad in
  let y = ref (2*pad) in
  let ln = ref 0 in
  let get_funs = function
    | "Plot" -> Some (Ui.size_plot, Either.Left Ui.widget_plot)
    | "NumDisplay" -> Some (Ui.size_numout, Either.Left Ui.widget_numout)
    | "BoolDisplay" -> Some (Ui.size_lcd, Either.Left Ui.widget_lcd)
    | "NumInput" -> Some (Ui.size_numin, Either.Right Ui.widget_numin)
    | "BoolInput" -> Some (Ui.size_button, Either.Right Ui.widget_button)
    | s -> if VASM.dev_of_string_opt s |> Option.is_none then InexistentType s |> raise else None in
  let find_source (name: string): string = 
    match List.find_opt (fun (x) -> match x with | AST.Link (_, Either.Left n) when n = name -> true | _ -> false) ast with
      | Some (AST.Link (expr, _)) -> Interface.string_of_expression expr
      | _ -> raise (DataSource name) in 
  let rec traverse (elements: string list) = function
    | h::t -> (match h with
      | AST.Init (ty, name, args) -> (match get_funs ty with
        | Some ((h, w), widget_fun) -> 
          x := !x + pad;
          let label_name = Util.find_args_def args "label" name in
          ln := !ln + 1;
          let label = Ui.widget_label !ln label_name !x (!y - pad) in 
          let widget = 
            match widget_fun with
              | Either.Left f -> f name !x !y (find_source name)
              | Either.Right f -> f name !x !y in
            x := !x + w;
            traverse (label::(widget::elements)) t
        | None -> traverse elements t)
      | _ -> traverse elements t)
    | [] -> elements in
  traverse [] ast;;

let get_output_devices (ast: Util.program_t) (dev_dict: VASM.devices_t): string list = 
  let rec traverse (elements: string list) = function
    | h::t -> (match h with
      | AST.Link (e, Either.Left s) -> (match Hashtbl.find_opt dev_dict s with
        | Some d ->
          traverse ((Ui.property_string (VASM.dev_to_string d) (Interface.string_of_expression e |> (if VASM.is_digital d then VASM.set_digital_python else VASM.set_analog_python) d))::elements) t
        | None -> traverse elements t)
      | _ -> traverse elements t)
    | [] -> elements in
  traverse [] ast;;

let get_init_config (ast: Util.program_t) (dev_dict: VASM.devices_t): bytes = 
  let dev_dict = VASM.dev_dict ast in
  let rec traverse (elements: bytes list) = function
    | h::t -> (match h with
      | AST.Init (ty, name, args) -> (match VASM.dev_of_string_opt ty with
        | Some dev -> traverse ((VASM.activate dev)::elements) t
        | None -> traverse elements t)
      | AST.Link (AST.Const f, Either.Left s) -> (match Hashtbl.find_opt dev_dict s with
        | Some d -> 
          if not (VASM.is_input d) then 
            if VASM.is_digital d then 
              traverse ((VASM.set_digital d (f <> 0.0))::elements) t 
            else 
              traverse ((VASM.set_analog d f)::elements) t 
          else traverse elements t
        | None -> traverse elements t)
      | _ -> traverse elements t)
    | [] -> elements in
  let byte_list = traverse [] ast in
  let header_byte = Bytes.create 1 in
    Bytes.set_uint8 header_byte 0 0xAA;
    List.fold_left Bytes.cat header_byte byte_list;;

let generate_config (path: string) (ast: Util.program_t): unit = ();;

let generate_ui (path: string) (ast: Util.program_t): unit = let file = open_out (path ^ "/program.ui") in
  let widgets = get_widgets ast in
  Printf.fprintf file "%s\n" (Ui.ui widgets);
  close_out file;;

let generate_init_config (path: string) (ast: Util.program_t): unit = 
  let put_bytes fn byts =
    let outc = open_out_bin fn in
    Bytes.iter (fun b -> output_char outc b) byts;
    close_out outc in
  put_bytes (path ^ "/program.init") (get_init_config ast (VASM.dev_dict ast));;

let () = let ast = get_AST "../GUI/Test/test.vdas" |> Util.process_AST in
  let dict = VASM.dev_dict ast in
  let widgets = get_widgets ast in
  let devices = get_output_devices ast dict in
  Printf.fprintf stdout "%s\n" (Ui.ui (List.rev_append widgets devices));;