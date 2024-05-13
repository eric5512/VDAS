from PySide6.QtWidgets import QDialog, QFileDialog

from ui_new import Ui_Dialog

class NewWindow(QDialog):
    __path: str = None

    def __init__(self):
        super(NewWindow, self).__init__()
        self.ui = Ui_Dialog()
        self.ui.setupUi(self)

        self.ui.buttonSelectFolder.clicked.connect(self.__click_selectFolder)

    def __click_selectFolder(self):
        self.__path = QFileDialog.getExistingDirectory(self)
        self.ui.linePath.setText(self.__path)

    def get_path(self) -> str:
        return self.__path
    
    def get_name(self) -> str:
        return self.ui.lineName.text()