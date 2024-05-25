import sys
from PySide6.QtWidgets import QApplication
import PySide6.QtWidgets
import pyqtgraph as pg

uiclass, baseclass = pg.Qt.loadUiType("program.ui")

class Program(uiclass, baseclass):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.plots = [a for _, a in self.__dict__.items() if type(a) == pg.PlotWidget]
        self.displays_num = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QLineEdit]
        self.inputs_num = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QDoubleSpinBox]
        self.buttons = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QPushButton]
        self.displays_bool = [a for _, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QLCDNumber]
        self.all = self.plots + self.displays_num + self.inputs_num + self.buttons + self.displays_bool
        print(self.plots)



app = QApplication(sys.argv)
window = Program()
window.show()
app.exec()