#ifndef VAPP_H
#define VAPP_H

#include <QWindow>

#include "program/vprogram.h"

class VApp : QWindow
{
public:
    VApp(VProgram*);
};

#endif // VAPP_H
