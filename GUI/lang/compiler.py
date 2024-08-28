from parser import parser
from typing import Tuple

class Compiler():
    __slots__ = ("__ast")

    def __init__(self, text: str) -> None:
        self.__ast = parser.parse(text)

    def compile() -> Tuple[str, bytes]:
        pass