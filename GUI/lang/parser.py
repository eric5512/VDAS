from lark import Lark, Transformer, v_args
from AST import *

# Lark grammar
grammar = """
?start: instruction

instruction: "define" ID NUM                -> def
           | expr "->" component            -> link
           | ID ID "(" [(args ","?)*] ")" -> init

args: ID "=" ESCAPED_STRING

?expr: NUM                                  -> const
     | component                            -> comp
     | operation

component: ID                                -> comp_name
         | ID ":" ID                         -> comp_with_attr

?operation: "(" operation ")"
          | expr "+" expr                    -> add
          | expr "-" expr                    -> sub
          | expr "*" expr                    -> mul
          | expr "/" expr                    -> div
          | expr "^" expr                    -> pow

%import common.CNAME -> ID
%import common.SIGNED_NUMBER -> NUM
%import common.ESCAPED_STRING
%import common.WS
%ignore WS
"""

# Transformer
class VLang(Transformer):
    def def_(self, items):
        name, value = items
        return AST.Def(name, float(value))
    
    def link(self, items):
        expr, comp = items
        return AST.Link(expr, comp)
    
    def init(self, items):
        type_, name, *args = items
        return AST.Init(type_, name, args)
    
    def args(self, items):
        return (items[0], items[1][1:-1])
    
    def const(self, items):
        return AST.Const(float(items[0]))

    def comp_name(self, items):
        return AST.Comp(items[0])
    
    def comp_with_attr(self, items):
        return AST.Comp(items[0], (items[0], items[2]))

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

# Initialize parser with the grammar and transformer
parser = Lark(grammar, parser='lalr', transformer=VLang())

if __name__ == "__main__":
    try:
        with open("./test/test.vdas") as program:
            parsed = parser.parse("Plot power(label = \"Power consumption\")")
            print(parsed)
    except Exception as e:
        print(e)
