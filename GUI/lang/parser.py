from lark import Lark, Transformer
from lang.AST import *

# Define grammar
grammar = """
start: instruction+

?instruction: "define" ID NUM                -> def_
           | operation "->" component       -> link
           | ID ID "(" [(args ","?)*] ")"   -> init

args: ID "=" ESCAPED_STRING

?operation: "(" operation ")"                -> paren_op
          | operation "+" operation         -> add
          | operation "-" operation         -> sub
          | operation "*" operation         -> mul
          | operation "/" operation         -> div
          | operation "^" operation         -> pow
          | NUM                             -> const
          | component

?component: ID                               -> comp_name
         | ID ":" ID                        -> comp_with_attr

%import common.CNAME -> ID
%import common.SIGNED_NUMBER -> NUM
%import common.ESCAPED_STRING
%import common.WS
%ignore WS
"""

# Transformer class
class VLang(Transformer):
    def start(self, items):
        return list(items)
    
    def def_(self, items):
        name, value = items
        return AST.Def(str(name), float(value))
    
    def link(self, items):
        expr, comp = items
        return AST.Link(expr, comp)
    
    def init(self, items):
        type_, name, *args = items
        return AST.Init(str(type_), str(name), [(str(i), str(j)) for i, j in args])
    
    def args(self, items):
        return (str(items[0]), items[1][1:-1])  # Remove quotes from the string value
    
    def const(self, items):
        return AST.Const(float(items[0]))

    def comp_name(self, items):
        return AST.Comp(str(items[0]))
    
    def comp_with_attr(self, items):
        return AST.Comp(str(items[0]), str(items[1]))

    def add(self, items):
        return AST.Op('Add', items[0], items[1])

    def sub(self, items):
        return AST.Op('Sub', items[0], items[1])

    def mul(self, items):
        return AST.Op('Mul', items[0], items[1])

    def div(self, items):
        return AST.Op('Div', items[0], items[1])

    def pow(self, items):
        return AST.Op('Pow', items[0], items[1])

    def paren_op(self, items):
        return items[0]  # Unwrap the operation from parentheses

# Initialize parser with the grammar and transformer
parser = Lark(grammar, start='start', parser='lalr', transformer=VLang())

if __name__ == "__main__":
    try:
        with open("./test/test2.vdas") as program:
            parsed = parser.parse(program.read())
            print(parsed)
    except Exception as e:
        print(e)
