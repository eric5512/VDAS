from dataclasses import dataclass
from typing import Union, Tuple, List

class AST:
    @dataclass
    class Comp:
        name: str
        attribute: str | None = None

    @dataclass
    class Op:
        operator: str
        left: 'AST.Op'
        right: 'AST.Op'

    @dataclass
    class Const:
        value: float

    Expr = Union['AST.Op', 'AST.Comp', 'AST.Const']

    @dataclass
    class Init:
        type: str
        name: str
        args: List[Tuple[str, str]]

    @dataclass
    class Def:
        name: str
        value: float

    @dataclass
    class Link:
        expr: 'AST.Expr'
        comp: 'AST.Comp'

    Ins = Union['AST.Init', 'AST.Def', 'AST.Link']

