#ifndef DESIGN_H
#define DESIGN_H

#include <QApplication>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QToolBar>
#include <QVBoxLayout>
#include <QTabWidget>
#include <QGraphicsScene>
#include <QList>

#include "vwidgets/vwidget.h"

class Design : public QGraphicsScene
{
public:
    Design();
    ~Design();
    bool saveDiagram(QString path);
private:
    QList<VWidget*> vwidgets;
};

#endif // DESIGN_H
