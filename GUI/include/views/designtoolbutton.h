#ifndef DESIGNTOOLBUTTON_H
#define DESIGNTOOLBUTTON_H

#include <QListWidgetItem>

#include "vwidgets/vwidget.h"

class DesignToolButton : public QListWidgetItem {
public:
    DesignToolButton();

private:
    QIcon icon;
    uint8_t tiles_x;
    uint8_t tiles_y;
    WidgetType::WidgetType type;
};

#endif // DESIGNTOOLBUTTON_H
