from PySide6.QtWidgets import QDialog, QFileDialog

from ui_load import Ui_Dialog

class LoadWindow(QDialog):
    __path: str = None

    def __init__(self):
        super(LoadWindow, self).__init__()
        self.ui = Ui_Dialog()
        self.ui.setupUi(self)

        self.ui.buttonSelectFile.clicked.connect(self.__click_selectFile)


    def __click_selectFile(self):
        self.__path, _ = QFileDialog.getOpenFileName(self)
        self.ui.linePath.setText(self.__path)

    def get_path(self) -> str:
        return self.__path