# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'newproject.ui'
##
## Created by: Qt User Interface Compiler version 6.7.0
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QAbstractButton, QApplication, QDialog, QDialogButtonBox,
    QLabel, QLineEdit, QPushButton, QSizePolicy,
    QWidget)

class Ui_Dialog(object):
    def setupUi(self, Dialog):
        if not Dialog.objectName():
            Dialog.setObjectName(u"Dialog")
        Dialog.resize(356, 158)
        self.buttonBox = QDialogButtonBox(Dialog)
        self.buttonBox.setObjectName(u"buttonBox")
        self.buttonBox.setEnabled(True)
        self.buttonBox.setGeometry(QRect(0, 110, 341, 32))
        self.buttonBox.setOrientation(Qt.Horizontal)
        self.buttonBox.setStandardButtons(QDialogButtonBox.Cancel|QDialogButtonBox.Ok)
        self.linePath = QLineEdit(Dialog)
        self.linePath.setObjectName(u"linePath")
        self.linePath.setGeometry(QRect(20, 30, 201, 20))
        self.linePath.setReadOnly(True)
        self.buttonSelectFolder = QPushButton(Dialog)
        self.buttonSelectFolder.setObjectName(u"buttonSelectFolder")
        self.buttonSelectFolder.setGeometry(QRect(230, 30, 75, 23))
        self.lineName = QLineEdit(Dialog)
        self.lineName.setObjectName(u"lineName")
        self.lineName.setGeometry(QRect(100, 70, 113, 20))
        self.label = QLabel(Dialog)
        self.label.setObjectName(u"label")
        self.label.setGeometry(QRect(30, 70, 71, 16))

        self.retranslateUi(Dialog)
        self.buttonBox.accepted.connect(Dialog.accept)
        self.buttonBox.rejected.connect(Dialog.reject)

        QMetaObject.connectSlotsByName(Dialog)
    # setupUi

    def retranslateUi(self, Dialog):
        Dialog.setWindowTitle(QCoreApplication.translate("Dialog", u"Dialog", None))
        self.buttonSelectFolder.setText(QCoreApplication.translate("Dialog", u"Select folder", None))
        self.label.setText(QCoreApplication.translate("Dialog", u"Project name:", None))
    # retranslateUi

