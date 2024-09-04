from PySide6.QtWidgets import QDialog

from windows.ui_connect import Ui_Dialog

import serial.tools.list_ports as get_ports

class ConnectWindow(QDialog):
    __devices = None

    def __init__(self):
        super(ConnectWindow, self).__init__()
        self.ui = Ui_Dialog()
        self.ui.setupUi(self)

        self.__devices = self.__get_devices()

        self.ui.comboDevice.addItems(map(lambda x: x.name, self.__devices))

    def __get_devices(self):
        return get_ports.comports()

    def get_device(self) -> str:
        return self.__devices[self.ui.comboDevice.currentIndex()].name