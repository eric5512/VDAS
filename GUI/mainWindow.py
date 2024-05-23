import sys

from PySide6.QtGui import QCloseEvent, QShortcut, QKeySequence
from PySide6.QtWidgets import QApplication, QMainWindow, QMessageBox

from windows.ui_window import Ui_MainWindow

from loadProject import LoadWindow
from newProject import NewWindow

from project import Project

class MainWindow(QMainWindow):
    project: Project

    def __init__(self):
        super(MainWindow, self).__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.project = Project()

        self.open_shortcut = QShortcut(QKeySequence("Ctrl+O"), self)
        self.open_shortcut.activated.connect(self.__click_actionOpen)
        self.ui.actionOpen.triggered.connect(self.__click_actionOpen)

        self.save_shortcut = QShortcut(QKeySequence("Ctrl+S"), self)
        self.save_shortcut.activated.connect(self.__click_actionSave)
        self.ui.actionSave.triggered.connect(self.__click_actionSave)

        self.new_shortcut = QShortcut(QKeySequence("Ctrl+N"), self)
        self.new_shortcut.activated.connect(self.__click_actionNew)
        self.ui.actionNew.triggered.connect(self.__click_actionNew)

        self.compile_shortcut = QShortcut(QKeySequence("Ctrl+G"), self)
        self.compile_shortcut.activated.connect(self.__click_actionCompile)
        self.ui.actionComplile.triggered.connect(self.__click_actionCompile)

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

    def __click_actionCompile(self) -> None:
        pass

    def __click_actionNew(self) -> None:
        new_window = NewWindow()
        new_window.setModal(True)
        new_window.setFixedSize(new_window.size())
        if new_window.exec():
            if (path := new_window.get_path()) != None:
                self.project = Project.new_project(path, new_window.get_name())
                self.ui.program.setText(self.project.get_text())

    def __click_actionSave(self) -> None:
        self.project.save(self.ui.program.toPlainText())

if __name__ == "__main__":
    app = QApplication(sys.argv)

    window = MainWindow()

    window.show()

    sys.exit(app.exec())