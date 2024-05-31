type size_t = int * int;;

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
</ui>";;

let property_string (name: string) (obj: string): string = Printf.sprintf ("<property name=\"%s\" stdset=\"0\">
<string>%s</string>
</property>") name obj;;

let property_bool (name: string) (obj: bool): string = Printf.sprintf ("<property name=\"%s\">
<bool>%b</bool>
</property>") name obj;;

let property_text_size (size: int): string = Printf.sprintf ("<property name=\"font\">
<font>
 <pointsize>%d</pointsize>
</font>
</property>") size;;

let property_text (text: string): string = Printf.sprintf ("<property name=\"text\">
<string>%s</string>
</property>") text;;

let property_geometry ((h, w): size_t) (x: int) (y: int): string = Printf.sprintf ("<property name=\"geometry\">
 <rect>
  <x>%d</x>
  <y>%d</y>
  <width>%d</width>
  <height>%d</height>
 </rect>
</property>") x y w h;;

let widget (clss: string) (name: string) (properties: string list): string = let jprops = List.fold_left (^) "" properties in Printf.sprintf ("<widget class=\"%s\" name=\"%s\">
%s
</widget>") clss name jprops;;

(* Widget sizes *)
let size_label: size_t = (20, 170);;

let size_plot: size_t = (280, 330);;

let size_numin: size_t = (30, 100);;

let size_numout: size_t = (30, 100);;

let size_button: size_t = (40, 100);;

let size_lcd: size_t = (30, 90);;

let size_window: size_t = (600, 800);;

(* Output widgets *)
let widget_label (num: int) (text: string) (x: int) (y: int): string = widget "QLabel" ("label_" ^ (string_of_int num)) [property_geometry size_label x y; property_text_size 10; property_text text];;

let widget_plot (name: string) (x: int) (y: int) (source: string): string = widget "PlotWidget" name [property_geometry size_plot x y; property_string "source" source];;

let widget_numout (name: string) (x: int) (y: int) (source: string): string = widget "QLineEdit" name [property_geometry size_numout x y; property_text_size 12; property_bool "readOnly" true; property_string "source" source];;

let widget_lcd (name: string) (x: int) (y: int) (source: string): string = widget "QLCDNumber" name [property_geometry size_lcd x y; property_string "source" source];;

(* Input widgets *)
let widget_numin (name: string) (x: int) (y: int): string = widget "QDoubleSpinBox" name [property_geometry size_numin x y; property_text_size 12];;

let widget_button (name: string) (x: int) (y: int): string = widget "QPushButton" name [property_geometry size_button x y; property_text_size 12; property_bool "checkable" true];;

(* Aux function to join the widgets*)
let ui (widgets: string list): string = let jwidgets = List.fold_left (^) "" widgets in header ^ jwidgets ^ footer;;