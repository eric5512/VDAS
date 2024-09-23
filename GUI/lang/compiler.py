from lang.parser import parser
from lang.AST import AST
import lang.UI as UI
import lang.VASM as VASM
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
        
class TypeError(Exception):
    def __init__(self, ty, variable) -> None:
        super().__init__(f"The element {variable} of type {ty} is incorrectly managed")

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
                    if (props := UI.clss_to_properties(ty)) != None:
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
                case AST.Link(l, r):
                    self.__links.append((l, r))
                case AST.Def(name, value):
                    if name not in self.__vars.keys():
                        self.__vars[name] = value
                    else:
                        raise VariableReassignment(name)
                case _:
                    raise RuntimeError("Unreacheable")
                
        self.__check()

    def __check(self): # TODO: Add more checks            
        def check_op(op: AST.Expr):
            match op:
                case AST.Op(_, l, r):
                    check_op(l)
                    check_op(r)
                case AST.Comp(name, _):
                    if name in self.__out_devices:
                        raise TypeError(self.__out_devices[name].name, name)
                    if name in self.__widgets:
                        ty = self.__widgets[name][0][0]
                        if ty not in ("QDoubleSpinBox", "QPushButton"):
                            raise TypeError(ty, name)

        for ins in self.__ast:
            match ins:
                case AST.Link(l, r):
                    if r.name in self.__in_devices:
                        raise TypeError(self.__in_devices[r.name].name, r.name)
                    if r.name in self.__widgets:
                        ty = self.__widgets[r.name][0][0]
                        if ty in ("QDoubleSpinBox", "QPushButton"):
                            raise TypeError(ty, r.name)
                    check_op(l)
                case _:
                    pass

    def compile(self) -> Tuple[str, bytes, 
                           List[Callable[[Callable[[str], float]], Callable[[], bytes]]], 
                           Dict[str, Callable[[Callable[[str], float]], Callable[[], float]]]]:
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
                    sources[right.name] = lambda finder, left=left, devices=self.__in_devices: Compiler.__op_to_func(left, finder, devices)
                else:
                    raise MultipleSources(right.name)
                
        return sources

    def __op_to_func(operation: AST.Op, finder: Callable[[str], float], devices: Dict[str, VASM.Device]) -> Callable[[], float]:
        def rec(op):
            match op:
                case AST.Op("Add", l, r):
                    return rec(l) + rec(r)
                case AST.Op("Sub", l, r):
                    return rec(l) - rec(r)
                case AST.Op("Mul", l, r):
                    return rec(l) * rec(r)
                case AST.Op("Div", l, r):
                    return rec(l) / rec(r)
                case AST.Op("Pow", l, r):
                    return rec(l) ** rec(r)
                case AST.Const(val):
                    return val
                case AST.Comp(name, _):
                    return finder(devices[name].name)
        return lambda: rec(operation)

    def __generate_ui(self) -> str:
        PAD = 20
        x = PAD
        y = 2*PAD
        ln = 0
        widgets = []
        for (element, properties) in self.__widgets.values():
            size, func = properties
            _, name, args = element
            h, w = size
            x += PAD
            ln += 1
            widgets.append(UI.widget_label(ln, Compiler.__find_arg_def(args, "label", name), x, y-PAD))
            widgets.append(func(name, x, y))
            x += w
            
        return UI.ui(widgets)

    def __get_output_commands(self) -> List[Callable[[Callable[[str], float]], Callable[[], bytes]]]:
        commands = []
        aux = set()
        for left, right in self.__links:
            if right.name in self.__out_devices.keys():
                if right.name not in aux:
                    aux.add(right.name)
                    match (dev := self.__out_devices[right.name]):
                        case VASM.Device.DAC0 | VASM.Device.DAC1:
                            commands.append(lambda finder, left=left, dev=dev: lambda: VASM.set_analog(dev, Compiler.__op_to_func(left, finder)()))
                        case _ if VASM.is_digital(dev):
                            commands.append(lambda finder, left=left, dev=dev: lambda: VASM.set_digital(dev, Compiler.__op_to_func(left, finder)()))
                        case _:
                            raise RuntimeError("Unreacheable")
                else:
                    raise MultipleSources(right.name)
                
        return commands
        

    def __get_config(self) -> bytes:
        config = b""
        for dev in self.__out_devices.values():
            if VASM.is_digital(dev):
                config += VASM.set_digital(dev, False)
            else:
                config += VASM.set_analog(dev, 0.0)
        for dev in self.__in_devices.values():
            config += VASM.activate(dev)
            
        return config
                
                
if __name__ == "__main__":
    with open("../test/test2.vdas") as f:
        print(Compiler(f.read()).compile())