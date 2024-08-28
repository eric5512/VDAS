from dataclasses import dataclass
from typing import Union, Tuple

class IR:
    @dataclass
    class VComp: # Visual component
        type_: str
        name: str

    @dataclass
    class DComp: # Digital component
        type_: str
        name: str

    @dataclass
    class Op:
        operator: str
        left: 'IR.Expr'
        right: 'IR.Expr'

    @dataclass
    class Const:
        value: float

    Expr = Union['IR.Op', 'IR.VComp', 'IR.DComp', 'IR.Const']

    @dataclass
    class Link:
        expr: 'IR.Expr'
        comp: Union[Tuple[Union['IR.DComp', 'IR.VComp'], str], Union['IR.DComp', 'IR.VComp']]

    Ins = Union['IR.Init', 'IR.Def', 'IR.Link']
