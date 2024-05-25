let header: string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
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
  <widget class=\"QWidget\" name=\"centralwidget\">";;

let footer: string = "</widget>
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
</ui>";;

type widget_t = string * int * int;; (* class name, height and width*)

let w_plot: widget_t = ("PlotWidget", 210, 280);;
let w_plot: widget_t = ("PlotWidget", 210, 280);;
let w_plot: widget_t = ("PlotWidget", 210, 280);;
let w_plot: widget_t = ("PlotWidget", 210, 280);;

let widget_geometry (h: int) (w: int) (name: string) (x: int) (y: int): string = Printf.sprintf ("<property name=\"geometry\">
 <rect>
  <x>%d</x>
  <y>%d</y>
  <width>%d</width>
  <height>%d</height>
 </rect>
</property>") x y w h;;

let widget (clss: string) (name: string) (properties: string list) = let jprops = List.fold_left (^) "" properties in Printf.sprintf ("<widget class=\"%s\" name=\"%s\">
%s
</widget>") clss name jprops;;