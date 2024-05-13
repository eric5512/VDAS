pyside6-uic mainWindow.ui -o ui_window.py
pyside6-uic loadproject.ui -o ui_load.py

py -3.12 .\mainWindow.py