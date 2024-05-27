let get_AST (path: string): Util.program_t = 
  let (ins, errs) = Util.get_lines (open_in path |> Lexing.from_channel) |> Util.process in
  if errs = [] then ins else failwith (List.hd errs);;

let get_widgets (ast: Util.program_t): (string list * (string -> string) list) = 
  let pad = 20 in
  let x = ref pad in
  let y = ref (2*pad) in
  let ln = ref 0 in
  let get_funs = function
    | "Plot" -> Some (Ui.size_plot, Ui.widget_plot)
    | "NumDisplay" -> Some (Ui.size_numout, Ui.widget_numout)
    | "NumInput" -> Some (Ui.size_numin, Ui.widget_numin)
    | "BoolDisplay" -> Some (Ui.size_lcd, Ui.widget_lcd)
    | "BoolInput" -> Some (Ui.size_button, Ui.widget_button)
    | _ -> None in
  let rec aux widgets labels = function
    | h::t -> (match h with
      | AST.Init (ty, n, args) -> (match get_funs ty with
        | Some ((h, w), widget_fun) -> 
          x := !x + pad;
          let label_name = Util.find_args_def args "label" n in
          ln := !ln + 1;
          let label = Ui.widget_label !ln label_name !x (!y - pad) in 
          let widget = widget_fun n !x !y in
            x := !x + w;
            aux (widget::widgets) (label::labels) t
        | None -> aux widgets labels t)
      | _ -> aux widgets labels t)
    | [] -> (labels, widgets) in
  aux [] [] ast;;

let bind_widgets (ast: Util.program_t) (widgets: (string -> string) list): string list = List.map (fun (x) -> x "test") widgets;;

let generate_ui (path: string) (ast: Util.program_t): unit = let file = open_out (path ^ "/program.ui") in
  let labels, widgets = get_widgets ast in
  Printf.fprintf file "%s\n" ((List.append (bind_widgets ast widgets) labels) |> Ui.ui);;

let () = let ast = get_AST "/mnt/c/Users/Eric/Desktop/Programas/GitHub/VDAS/GUI/Test/test.vdas" |> Util.process_AST in
  let (labels, widgets) = get_widgets ast in
  Printf.fprintf stdout "%s\n" ((List.append (bind_widgets ast widgets) labels) |> Ui.ui);;