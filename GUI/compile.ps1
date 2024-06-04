$views = @("mainWindow", "loadproject", "newproject", "connect")

for ($i = 0; $i -lt $views.Count; $i++) {
    pyside6-uic windows/$($views[$i]).ui -o windows/ui_$($views[$i]).py
}

py -3.12 .\mainWindow.py