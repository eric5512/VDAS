from lark import Lark, Transformer, v_args
from AST import *

# Lark grammar
grammar = """
?start: instruction

instruction: "define" ID NUM                -> def
           | expr "->" component            -> link
           | ID ID "(" [args ("," args)*] ")" -> init

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
        return Def(name, float(value))
    
    def link(self, items):
        expr, comp = items
        return Link(expr, comp)
    
    def init(self, items):
        type_, name, *args = items
        args_list = [tuple(arg.children) for arg in args[0].children] if args else []
        return Init(type_, name, args_list)
    
    def args(self, items):
        return (items[0], items[1][1:-1])
    
    def const(self, items):
        return Const(float(items[0]))

    def comp_name(self, items):
        return Comp(items[0])
    
    def comp_with_attr(self, items):
        return Comp(items[0], (items[0], items[2]))

    def add(self, items):
        return Op('Add', items[0], items[1])

    def sub(self, items):
        return Op('Sub', items[0], items[1])

    def mul(self, items):
        return Op('Mul', items[0], items[1])

    def div(self, items):
        return Op('Div', items[0], items[1])

    def pow(self, items):
        return Op('Pow', items[0], items[1])

# Initialize parser with the grammar and transformer
parser = Lark(grammar, parser='lalr', transformer=VLang())

# Example usage
try:
    parsed = parser.parse('define x 42\n')
    print(parsed)
except Exception as e:
    print(e)
