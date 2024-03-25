#include "vlabel.h"

VLabel::VLabel(QString text) : VWidget(WidgetType::Label) {
    this->text = text;
}
