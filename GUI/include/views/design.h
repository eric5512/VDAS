#ifndef DESIGN_H
#define DESIGN_H

#include <QWidget>

#include "vwidgets/vwidget.h"

class Design : public QWidget {
public:
    Design();
    ~Design();
    bool saveDiagram(QString path);
private:
    struct Element {
        VWidget* widget;
        QPoint positon;

        Element(VWidget* widget, const QPoint& pos) {
            this->widget = widget;
            this->positon = pos;
        }

        ~Element() {
            delete this->widget;
        }
    };

    const QSize tile_size = QSize(5,5); // Tile size in mm
    const QSize n_tiles = QSize(20,20); // Number of tiles in the grid



    QList<Element*> vwidgets;
};

#endif // DESIGN_H
