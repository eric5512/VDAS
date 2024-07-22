import sys
from PySide6.QtWidgets import QApplication
from PySide6.QtGui import QCloseEvent
import PySide6.QtWidgets
import pyqtgraph as pg
from serialInterface import SerialInterface
from threading import Thread

def createProgram():
    uiclass, baseclass = pg.Qt.loadUiType("program.ui")
    class Program(uiclass, baseclass):
        def __init__(self, port):
            super().__init__()
            self.setupUi(self)
            self.inputs = { n:a for n, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QPushButton or type(a) == PySide6.QtWidgets.QDoubleSpinBox }
            self.outputs = { n:a for n, a in self.__dict__.items() if type(a) == PySide6.QtWidgets.QLineEdit or type(a) == PySide6.QtWidgets.QLCDNumber or type(a) == pg.PlotWidget }
            self.bindings = { n:(Program.__get_source(a)) for n, a in self.outputs.items() }
            self.plot_data = { n:[] for n, a in self.outputs.items() if type(a) == pg.PlotWidget }
            self.commands = dict()
            # for w in self.inputs:
            #     if 
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

            for i in self.inputs.values():
                if type(i) == PySide6.QtWidgets.QPushButton:
                    i.clicked.connect(self.__send_commands)
                if type(i) == PySide6.QtWidgets.QDoubleSpinBox:
                    i.valueChanged.connect(self.__send_commands)

            SerialInterface.connect(port)

            try:
                with open("./init", "rb") as f:
                    init = f.read()
                    SerialInterface.send_command(init)
            except:
                pass

            read_thread = Thread(target=SerialInterface.receive_data_process, args=(self.__receive_data,))
            read_thread.start()

        def closeEvent(self, event: QCloseEvent) -> None:
            SerialInterface.close()

        def __send_commands(self):
            for i in self.commands:
                by = eval(i)
                SerialInterface.send_command(by)

        def __find(self, name):
            if name in self.data:
                return self.data[name]
            if name in self.inputs:
                element = self.inputs[name]
                if type(element) == PySide6.QtWidgets.QPushButton:
                    return 1 if element.isChecked() else 0
                if type(element) == PySide6.QtWidgets.QDoubleSpinBox:
                    return element.value()
            
            raise KeyError(f"Non existent value: {name}")

        def __refresh(self, name):
            element = self.outputs[name]
            value = self.bindings[name]
            
            if type(element) == PySide6.QtWidgets.QLineEdit:
                element.setText(str(eval(value)))

            if type(element) == PySide6.QtWidgets.QLCDNumber:
                element.display(0 if eval(value) == 0 else 1)

            if type(element) == pg.PlotWidget:
                self.__plot_add_point(name, value)

        def __plot_reset(self, name):
            self.plot_data[name] = []
            self.outputs[name].plot(self.plot_data[name])

        def __receive_data(self, data):
            name, value = data
            if name == "DI":
                self.data["DI0"] = 1 if value & (0b1 << 0) != 0 else 0
                self.data["DI1"] = 1 if value & (0b1 << 1) != 0 else 0
                self.data["DI2"] = 1 if value & (0b1 << 2) != 0 else 0
                self.data["DI3"] = 1 if value & (0b1 << 3) != 0 else 0
                self.data["DI4"] = 1 if value & (0b1 << 4) != 0 else 0
                self.data["DI5"] = 1 if value & (0b1 << 5) != 0 else 0
                self.data["DI6"] = 1 if value & (0b1 << 6) != 0 else 0
                self.data["DI7"] = 1 if value & (0b1 << 7) != 0 else 0
            else:
                self.data[name] = value
            self.__reload_ui()

        def __reload_ui(self):
            for k in self.outputs:
                self.__refresh(k)

        def __plot_add_point(self, name, value):
            self.plot_data[name].append(value)
            self.outputs[name].plot(self.plot_data[name])

        def __get_source(widget):
            return widget.property("source")
        
    return Program

if __name__ == "__main__":
    app = QApplication(sys.argv)
    program = createProgram()("COM6")
    program.show()
    app.exec()