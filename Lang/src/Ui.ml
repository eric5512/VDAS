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

let property_read_only: string = "<property name=\"readOnly\">
<bool>true</bool>
</property>";;

let property_checkable: string = "<property name=\"checkable\">
<bool>true</bool>
</property>";;

let property_text_size (size: int): string = Printf.sprintf ("<property name=\"font\">
<font>
 <pointsize>%d</pointsize>
</font>
</property>") size;;

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

let size_label: size_t = (20, 170);;

let size_plot: size_t = (210, 80);;

let size_numin: size_t = (30, 100);;

let size_numout: size_t = (30, 100);;

let size_button: size_t = (40, 100);;

let size_lcd: size_t = (30, 90)

let widget_label (num: int) (text: string) (x: int) (y: int): string = widget "QLabel" ("label_" ^ (string_of_int num)) [property_geometry size_label x y; property_text_size 10];;

let widget_plot (name: string) (x: int) (y: int): string = widget "PlotWidget" name [property_geometry size_plot x y];;

let widget_numin (name: string) (x: int) (y: int): string = widget "QDoubleSpinBox" name [property_geometry size_numin x y; property_text_size 12];;

let widget_numout (name: string) (x: int) (y: int): string = widget "QLineEdit" name [property_geometry size_numout x y; property_text_size 12; property_read_only];;

let widget_button (name: string) (x: int) (y: int): string = widget "QPushButton" name [property_geometry size_button x y; property_text_size 12; property_checkable];;

let widget_lcd (name: string) (x: int) (y: int): string = widget "QLCDNumber" name [property_geometry size_lcd x y];;

let ui (widgets: string list): string = let jwidgets = List.fold_left (^) "" widgets in header ^ jwidgets ^ footer;;