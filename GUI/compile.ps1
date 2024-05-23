pyside6-uic windows/mainWindow.ui -o windows/ui_window.py
pyside6-uic windows/loadproject.ui -o windows/ui_load.py
pyside6-uic windows/newproject.ui -o windows/ui_new.py

py -3.12 .\mainWindow.py