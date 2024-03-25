#ifndef VLABEL_H
#define VLABEL_H

#include "vwidget.h"

class VLabel : public VWidget
{
public:
    VLabel(QString);

    void setText(QString new_text) { text = new_text; }
    QString getText() { return text; }
private:
    QString text;
};

#endif // VLABEL_H
