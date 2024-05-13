import sys

from PySide6.QtGui import QCloseEvent
from PySide6.QtWidgets import QApplication, QMainWindow, QMessageBox

from ui_window import Ui_MainWindow

from loadProject import LoadWindow

from project import Project

class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.project = Project()

        self.ui.actionOpenProyect.triggered.connect(self.__click_actionOpen)
        self.ui.actionSave.triggered.connect(self.__click_actionSave)

    def closeEvent(self, event: QCloseEvent) -> None:
        self.project.close()
        return super().closeEvent(event)

    def __click_actionOpen(self) -> None:
        load_window = LoadWindow()
        load_window.setModal(True)
        load_window.setFixedSize(load_window.size())
        if load_window.exec():
            if (path := load_window.get_path()) != None:
                self.project = Project.load_project(path)
                self.ui.program.setText(self.project.get_text())

    def __click_actionSave(self) -> None:
        self.project.save(self.ui.program.toPlainText())

if __name__ == "__main__":
    app = QApplication(sys.argv)

    window = MainWindow()

    window.show()

    sys.exit(app.exec())