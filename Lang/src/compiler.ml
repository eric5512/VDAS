exception DataSource of string;;

let get_AST (path: string): Util.program_t = 
  let (ins, errs) = Util.get_lines (open_in path |> Lexing.from_channel) |> Util.process in
  if errs = [] then ins else failwith (List.hd errs);;

let get_widgets (ast: Util.program_t): string list = 
  let (win_h, win_w) = Ui.size_window in
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
    | _ -> None in
  let find_source (name: string): string = 
    match List.find_opt (fun (x) -> match x with | AST.Link (_, Either.Left n) when n = name -> true | _ -> false) ast with
      | Some (AST.Link (expr, _)) -> Util.string_of_expression expr
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

let get_config (ast: Util.program_t): string = ;;

let generate_config (path: string) (ast: Util.program_t): unit = ();;

let generate_ui (path: string) (ast: Util.program_t): unit = let file = open_out (path ^ "/program.ui") in
  let widgets = get_widgets ast in
  Printf.fprintf file "%s\n" (Ui.ui widgets);;

let () = let ast = get_AST "/mnt/c/Users/Eric/Desktop/Programas/GitHub/VDAS/GUI/Test/test.vdas" |> Util.process_AST in
  let widgets = get_widgets ast in
  Printf.fprintf stdout "%s\n" (Ui.ui widgets);;