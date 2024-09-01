from typing import List, Tuple, Callable

HEADER = """<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ui version=\"4.0\">
 <class>MainWindow</class>
 <widget class=\"QMainWindow\" name=\"MainWindow\">
  <property name=\"geometry\">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>800</width>
    <height>600</height>
   </rect>
  </property>
  <property name=\"windowTitle\">
   <string>Program</string>
  </property>
  <widget class=\"QWidget\" name=\"centralwidget\">"""

FOOTER = """</widget>
</widget>
<customwidgets>
  <customwidget>
    <class>PlotWidget</class>
    <extends>QWidget</extends>
    <header>pyqtgraph</header>
    <container>1</container>
  </customwidget>
</customwidgets>
<resources/>
<connections/>
</ui>"""

property_string = lambda name, obj: f"""<property name=\"{name}\" stdset=\"0\">
<string>{obj}</string>
</property>"""

property_bool = lambda name, obj: f"""<property name=\"{name}\">
<bool>{obj}</bool>
</property>"""

property_text_size = lambda size: f"""<property name=\"font\">
<font>
 <pointsize>{size}</pointsize>
</font>
</property>"""

property_text = lambda text: f"""<property name=\"text\">
<string>{text}</string>
</property>"""

property_geometry = lambda h, w, x, y: f"""<property name=\"geometry\">
 <rect>
  <x>{x}</x>
  <y>{y}</y>
  <width>{w}</width>
  <height>{h}</height>
 </rect>
</property>"""

def widget(clss: str, name: str, properties: List[str]):
    jprops = "".join(properties)
    return f"""<widget class=\"{clss}\" name=\"{name}\">
{jprops}
</widget>"""

# (* Widget sizes *)
SIZE_LABEL = (20, 170)

SIZE_PLOT = (280, 330)

SIZE_NUMIN = (30, 100)

SIZE_NUMOUT = (30, 100)

SIZE_BUTTON = (40, 100)

SIZE_LCD = (30, 90)

SIZE_WINDOW = (600, 800)

# (* Output widgets *)
widget_label = lambda num, text, x, y: widget("QLabel", f"label_{num}", [property_geometry(SIZE_LABEL, x, y), property_text_size(10), property_text(text)])

widget_plot = lambda name, x, y: widget("PlotWidget", name, [property_geometry(SIZE_PLOT, x, y)])

widget_numout = lambda name, x, y:widget ("QLineEdit", name, [property_geometry(SIZE_NUMOUT, x, y), property_text_size(12), property_bool("readOnly", True)])

widget_lcd = lambda name, x, y: widget("QLCDNumber", name, [property_geometry(SIZE_LCD, x, y)])

# (* Input widgets *)
widget_numin = lambda name, x, y: widget("QDoubleSpinBox", name, [property_geometry(SIZE_NUMIN, x, y), property_text_size(12)])

widget_button = lambda name, x, y: widget("QPushButton", name, [property_geometry(SIZE_BUTTON, x, y), property_text_size(12), property_bool("checkable", True)])

# (* Aux function to join the widgets*)
def ui(widgets: List[str]):
    jwidgets = "".join(widgets)
    return HEADER + jwidgets + FOOTER

def clss_to_properties(name: str) -> Tuple[Tuple[int, int], Callable] | None:
  match name:
    case "Plot":
      return (SIZE_PLOT, widget_plot)
    case "NumDisplay":
      return (SIZE_NUMOUT, widget_numout)
    case "BoolDisplay":
      return (SIZE_LCD, widget_lcd)
    case "NumInput":
      return (SIZE_NUMIN, widget_numin)
    case "BoolInput":
      return (SIZE_BUTTON, widget_button)
    case _:
      return None