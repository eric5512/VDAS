#ifndef VWIDGET_H
#define VWIDGET_H

#include <QQueue>
#include <QSize>

namespace WidgetType{
    enum WidgetType {
        Label,
        Graph,
        NumericDisplay,
        BinaryDisplay,
        Button
    };
}

class VWidget {
public:
    VWidget(WidgetType type) { size = getWidgetSize(type); }
    QSize getSize() { return size; }
    static QSize getWidgetSize(WidgetType);
    virtual execute() = 0;
private:
protected:
    QSize size;
};


#endif // VWIDGET_H
