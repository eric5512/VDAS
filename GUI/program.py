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
        self.bindings = { n:(Program.get_source(a)) for n, a in self.outputs.items()}
        self.plot_data = { n:[] for n, a in self.outputs.items() if type(a) == pg.PlotWidget}
        self.commands = [v for i in ["DAC0", "DAC1", "DO0", "DO1", "DO2", "DO3", "DO4", "DO5", "DO6", "DO7"] if (v := self.centralwidget.property(i)) != None]
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
            element = self.inputs[name]
            if type(element) == PySide6.QtWidgets.QPushButton:
                return 1 if element.isChecked() else 0
            if type(element) == PySide6.QtWidgets.QDoubleSpinBox:
                return element.value()
        
        raise KeyError(f"Non existent value: {name}")

    def refresh(self, name):
        element = self.outputs[name]
        value = self.bindings[name]
        
        if type(element) == PySide6.QtWidgets.QLineEdit:
            element.setText(str(eval(value)))

        if type(element) == PySide6.QtWidgets.QLCDNumber:
            element.display(0 if eval(value) == 0 else 1)

        if type(element) == pg.PlotWidget:
            self

    def plot_add_point(self, value, name):
        self.plot_data[name].append(value)
        self.outputs[name].plot(self.plot_data[name])

    def get_source(widget):
        return widget.property("source")

app = QApplication(sys.argv)
program = Program()
program.show()
app.exec()