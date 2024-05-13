from io import TextIOWrapper
from typing import Self

class Project:
    __resource: TextIOWrapper

    def __init__(self) -> None:
        self.__resource = None

    def close(self) -> None:
        if self.is_empty():
            self.__resource.close()

    def get_text(self) -> str:
        text = self.__resource.read()
        self.__resource.seek(0)
        return text
    
    def is_empty(self) -> bool:
        return self.__resource != None
    
    def save(self, text: str) -> bool:
        if self.is_empty():
            return False
    
        self.__resource.truncate()
        self.__resource.write(text)
        self.__resource.flush()

        return True
    
    def load_project(path: str) -> Self:
        proj = Project()
        res = open(path, "+r")
        proj.__resource = res
        return proj
    