from parser import parser
from AST import AST
import UI
import VASM
from typing import Tuple, Dict, Callable, List, Any

class DataSource(Exception):
    def __init__(self, name: str) -> None:
        super().__init__(f"Missing data source for element named {name}")

class InexistentType(Exception):
    def __init__(self, type: str) -> None:
        super().__init__(f"Type {type} does not exist")

class VariableReassignment(Exception):
    def __init__(self, name: str) -> None:
        super().__init__(f"Redefining variable {name}")

class ElementRedefinition(Exception):
    def __init__(self, name: str) -> None:
        super().__init__(f"Trying to redefine element named {name}")

class MultipleSources(Exception):
    def __init__(self, name) -> None:
        super().__init__(f"The element {name} has multiple data sources")

class Compiler():
    __slots__ = ("__ast", "__widgets", "__in_devices", "__out_devices", "__links", "__vars")

    def __init__(self, text: str) -> None:
        self.__ast = parser.parse(text)
        self.__widgets = dict()
        self.__in_devices = dict()
        self.__out_devices = dict()
        self.__links = []
        self.__vars = dict()
        for element in self.__ast:
            match element:
                case AST.Init(ty, name, args):
                    if (props := UI.clss_to_properties()) != None:
                        if name not in self.__widgets.keys():
                            self.__widgets[name] = ((ty, name, args), props)
                        else:
                            raise ElementRedefinition(name)
                    elif VASM.is_device(element):
                        dev = VASM.Device[ty]
                        d = self.__in_devices if VASM.is_input(dev) else self.__out_devices
                        if name not in d.keys():
                            d[name] = dev
                        else:
                            raise ElementRedefinition(name)
                    else:
                        raise InexistentType(element.type)
                case AST.Link(*atts):
                    self.__links.append(atts)
                case AST.Def(name, value):
                    if name not in self.__vars.keys():
                        self.__vars[name] = value
                    else:
                        raise VariableReassignment(name)
                case _:
                    raise RuntimeError("Unreacheable")

    def compile(self) -> Tuple[str, bytes, 
                           Dict[str, Callable[[int], bytes]], 
                           Dict[str, Callable[[], None]]]:
        ui = self.__generate_ui()
        config = self.__get_config()
        commands = self.__get_output_commands()
        sources = self.__get_sources()

        return ui, config, commands, sources

    def __find_arg_def(args: List[Tuple[str, str]], name: str, default: str) -> str:
        for (n, a) in args:
            if n == name:
                return a
        
        return default
    
    def __get_sources(self) -> Dict[str, Callable[[Callable[[str], float]], Callable[[], float]]]:
        sources = dict()
        for left, right in self.__links:
            if right.name in self.__widgets.keys():
                if right.name not in sources.keys():
                    sources[right.name] = lambda finder: Compiler.__op_to_func(left, finder)
                else:
                    raise MultipleSources(right.name)

    def __op_to_func(operation: AST.Op, finder: Callable[[str], float]) -> Callable[[], float]:
        pass # TODO: Add conversion from AST op to python function

    def __generate_ui(self) -> str:
        PAD = 20
        x = PAD
        y = 2*PAD
        ln = 0
        widgets = []
        for (element, properties) in self.__widgets:
            size, func = properties
            _, name, args = element
            h, w = size
            x += PAD
            ln += 1
            widgets.append(UI.widget_label(ln, Compiler.__find_arg_def(args, "label", name), x, y-PAD))
            widgets.append(func(name, x, y))
            x += w

    def __get_output_commands(self) -> List[Callable[[Callable[[str], float]], Callable[[], float]]]:
        commands = []
        for left, right in self.__links:
            if right.name in self.__out_devices.keys():
                commands.append(lambda finder: Compiler.__op_to_func(left, finder))

    def __get_config(self):
        pass
# let get_init_config (ast: Util.program_t) (dev_dict: VASM.devices_t): bytes Option.t = 
#   let dev_dict = VASM.dev_dict ast in
#   let rec traverse (elements: bytes list) = function
#     | h::t -> (match h with
#       | AST.Init (ty, name, args) -> (match VASM.dev_of_string_opt ty with
#         | Some dev -> if VASM.is_input dev then traverse ((VASM.activate dev)::elements) t else traverse elements t
#         | None -> traverse elements t)
#       | AST.Link (AST.Const f, Either.Left s) -> (match Hashtbl.find_opt dev_dict s with
#         | Some d -> 
#           if not (VASM.is_input d) then 
#             if VASM.is_digital d then 
#               traverse ((VASM.set_digital d (f=0.0))::elements) t 
#             else 
#               traverse ((VASM.set_analog d f)::elements) t
#           else traverse elements t
#         | None -> traverse elements t)
#       | _ -> traverse elements t)
#     | [] -> elements in
#   let byte_list = traverse [] ast in
#     if (List.length byte_list) <> 0 then Some (List.fold_left Bytes.cat (List.hd byte_list) (List.tl byte_list)) else None;;

# let () = let ast = get_AST (Sys.argv.(1))  |> Util.process_AST in
#   let dict = VASM.dev_dict ast in
#   let widgets = get_widgets ast dict in
#   let devices = get_output_devices ast dict in
#   let init = get_init_config ast dict in
#   let init_file = open_out_bin Sys.argv.(2) in
#     Printf.fprintf stdout "%s\n" (Ui.ui (List.rev_append widgets devices));
#     if Option.is_some init then Option.get init |> output_bytes init_file;
#     close_out init_file;;