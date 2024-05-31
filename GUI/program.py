import sys
from PySide6.QtWidgets import QApplication
import PySide6.QtWidgets
import pyqtgraph as pg

uiclass, baseclass = pg.Qt.loadUiType("program.ui")

class Program(uiclass, baseclass):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.inputs = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QPushButton or type(a) == PySide6.QtWidgets.QDoubleSpinBox]
        self.outputs = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QLineEdit or type(a) == PySide6.QtWidgets.QLCDNumber or type(a) == pg.PlotWidget]
        self.all = self.inputs + self.outputs

    def get_binding(widget):
        return widget.property("binding")

app = QApplication(sys.argv)
program = Program()
program.show()
app.exec()