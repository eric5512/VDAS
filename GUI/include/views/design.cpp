#include <QTabWidget>

#include "design.h"

Design::Design() {
    this->vwidgets = QList<Element*>();
}

Design::~Design() {
    for (Element* item : vwidgets) {
        delete item;
    }
}
