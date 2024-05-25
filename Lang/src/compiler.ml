let get_AST (path: string): Util.program_t = Util.get_lines (open_in path |> Lexing.from_channel) |> Util.process;;

let get_widgets (ast: Util.program_t): string list = 
  let pad = 10 in
  let x = ref 0 in
  let y = ref 0 in
  let get_funs = function
    | "Plot" -> Some (Ui.size_plot, Ui.widget_plot)
    | "NumDisplay" -> Some (Ui.size_numout, Ui.widget_numout)
    | "NumInput" -> Some (Ui.size_numin, Ui.widget_numin)
    | "BoolDisplay" -> Some (Ui.size_lcd, Ui.widget_lcd)
    | "BoolInput" -> Some (Ui.size_button, Ui.widget_button)
    | _ -> None in
  let rec aux acc = function
    | h::t -> (match h with
      | AST.Init (ty, n, _) -> (match get_funs ty with
        | Some ((h, w), widget_fun) -> 
          x := !x + pad;
          let widget = widget_fun n !x !y in
            x := !x + w;
            aux (widget::acc) t
        | None -> aux acc t)
      | _ -> aux acc t)
    | [] -> [] in
  aux [] ast;;

let generate_ui (path: string) (ast: Util.program_t): unit = let file = open_out (path ^ "/program.ui") in
  Printf.fprintf file "%s\n" (get_widgets ast |> Ui.ui);;