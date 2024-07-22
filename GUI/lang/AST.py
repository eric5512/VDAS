from dataclasses import dataclass
from typing import List, Tuple, Union

@dataclass
class Comp:
    name: str
    attribute: Tuple[str, str] = None

@dataclass
class Op:
    operator: str
    left: 'Expr'
    right: 'Expr'

@dataclass
class Const:
    value: float

Expr = Union[Op, Comp, Const]

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
    expr: Expr
    comp: Comp

Ins = Union[Init, Def, Link]