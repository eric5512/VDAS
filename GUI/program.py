import sys
from PySide6.QtWidgets import QApplication
import PySide6.QtWidgets
import pyqtgraph as pg

uiclass, baseclass = pg.Qt.loadUiType("program.ui")

class Program(uiclass, baseclass):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.inputs = { n:a for n, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QPushButton or type(a) == PySide6.QtWidgets.QDoubleSpinBox}
        self.outputs = { n:a for n, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QLineEdit or type(a) == PySide6.QtWidgets.QLCDNumber or type(a) == pg.PlotWidget}
        self.bindings = { n:(Program.get_binding(a)) for n, a in self.inputs.items() }
        self.data = {
            "ADC0": 0,
            "ADC1": 0,
            "CADC0": 0,
            "CADC1": 0,
            "DI0": 0,
            "DI1": 0,
            "DI2": 0,
            "DI3": 0,
            "DI4": 0,
            "DI5": 0,
            "DI6": 0,
            "DI7": 0,
        }

    def find(self, name):
        if name in self.data:
            return self.data[name]
        if name in self.inputs:
            return self.inputs[name]
        if name in self.outputs:
            return self.outputs[name]
        
        raise KeyError(f"Non existent value: {name}")

    def refresh():
        pass

    def get_source(widget):
        return widget.property("source")

app = QApplication(sys.argv)
program = Program()
program.show()
app.exec()