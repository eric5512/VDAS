#include <QTabWidget>

#include "design.h"

Design::Design() {
    this->vwidgets = QList<VWidget*>();
}

Design::~Design() {
    for (VWidget* item : vwidgets) {
        delete item;
    }
}
