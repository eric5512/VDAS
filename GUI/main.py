import sys
import subprocess

from PySide6.QtGui import QCloseEvent, QShortcut, QKeySequence
from PySide6.QtWidgets import QApplication, QMainWindow, QMessageBox
from PySide6.QtCore import Qt

from windows.ui_window import Ui_MainWindow

from windows.loadProject import LoadWindow
from windows.newProject import NewWindow
from windows.connect import ConnectWindow

from project.project import Project
from program.program import createProgram
from lang.compiler import Compiler


def create_error_box(title, text):
    msg = QMessageBox()
    msg.setIcon(QMessageBox.Critical)
    msg.setWindowTitle(title)
    msg.setText(text)
    msg.exec_()

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
        if not self.project.is_empty():
            try:
                connect = ConnectWindow()
                self.project.save(self.ui.program.toPlainText())
                
                if connect.exec():
                    compiler = Compiler(self.ui.program.toPlainText())
                    ui, config, commands, sources = compiler.compile()
                    with open("program.ui", "+wt") as program_file:
                        program_file.write(ui)
                    self.program = createProgram()(connect.get_device(), config, commands, sources)
                    self.program.setAttribute(Qt.WA_DeleteOnClose)  # Ensure the program window emits the destroyed signal
                    self.program.show()
                    self.setEnabled(False)
                    self.program.destroyed.connect(self.__on_program_closed)
            except Exception as e:
                create_error_box("Error during compilation", str(e))
                
        else:
            create_error_box("Error: empty project", "No selected project")

    def __on_program_closed(self):
        self.setEnabled(True)

    def __click_actionNew(self) -> None:
        new_window = NewWindow()
        new_window.setModal(True)
        new_window.setFixedSize(new_window.size())
        if new_window.exec():
            if (path := new_window.get_path()) != None:
                self.project = Project.new_project(path, new_window.get_name())
                self.ui.program.setText(self.project.get_text())

    def __click_actionSave(self) -> None:
        if not self.project.is_empty():
            self.project.save(self.ui.program.toPlainText())
            ls = subprocess.Popen(["wsl", "../Lang/compiler", self.project.path.replace("\\", "/").replace("C:", "/mnt/c"), "./init"], stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            ls.wait()
            if ls.returncode == 0:
                self.ui.output.setText("No errors found")
                ls.stdout.read().decode()
            else:
                self.ui.output.setText(ls.stderr.read().decode())
                
        else:
            create_error_box("Error: empty project", "No selected project")


if __name__ == "__main__":
    app = QApplication(sys.argv)

    window = MainWindow()

    window.show()

    sys.exit(app.exec())