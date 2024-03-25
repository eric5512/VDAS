#include "vwidget.h"

QSize VWidget::getWidgetSize(WidgetType::WidgetType type) {
    switch (type) {
    case WidgetType::Label:
        return QSize();
    case WidgetType::Graph:
        return QSize();
    case WidgetType::Button:
        return QSize();
    case WidgetType::NumericDisplay:
        return QSize();
    case WidgetType::BinaryDisplay:
        return QSize();
    }
}
