#include <QGraphicsView>

#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "views/design.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    Design design_view = Design();
    ui->graphicsDesignView;
}

MainWindow::~MainWindow()
{
    delete ui;
}

