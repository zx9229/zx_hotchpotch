#include "my_dock_widget.h"
#include "my_title_bar_widget.h"
#include "mainwindow.h"
#include <QMenuBar>
#include <QPushButton>
#include <QPlainTextEdit>
#include <QMessageBox>
#include <QDateTime>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    m_widgetIndex = 0;
    m_widgets.clear();
    m_dockWidgetType = 0;
    createUi();
}

MainWindow::~MainWindow()
{
    m_widgets.clear();
}

void MainWindow::createUi()
{
    this->setDockOptions(QMainWindow::AnimatedDocks | QMainWindow::AllowNestedDocks | QMainWindow::AllowTabbedDocks | QMainWindow::GroupedDragging);
    this->setAttribute(Qt::WA_DeleteOnClose, true);  // MainWindow在close的时候就destory.

    QMenuBar* menuBar = new QMenuBar(this);
    if (true) {
        QMenu* curMenu = new QMenu(tr("操作一览"), this);
        curMenu->addAction(tr("增加DockWidget"), this, SLOT(slotAddDockWidget()));
        curMenu->addAction(tr("设置DockWidget类型"), this, SLOT(slotSetDockWidgetType()));
        menuBar->addMenu(curMenu);
    }
    this->setMenuBar(menuBar);

    QString styleSheet;
    //styleSheet += "QMainWindow { background : #B7B7B7 }";
    styleSheet += "QMainWindow::separator:hover { background : #878787 }";
    //styleSheet += "QMenuBar { background-color: #C7C7C7 }";
    //styleSheet += "QStatusBar { background-color: #C9C9C9 }";
    this->setStyleSheet(styleSheet);
}

QDockWidget* MainWindow::createDockWidget(QWidget* parent, const QString& title, int type)
{
    QDockWidget* curDockWidget = nullptr;
    if (type == 0) {
        curDockWidget = new QDockWidget(title, parent);
    }
    else if (type == 1) {
        MyDockWidget* myObj = new MyDockWidget(title, parent);
        QObject::connect(myObj, &MyDockWidget::sigContextMenuEvent,
            [myObj](QContextMenuEvent*) {
            QMenu *menu = new QMenu(myObj);
            myObj->fillDefaultActions(menu);
            menu->exec(myObj->cursor().pos());
        });
        curDockWidget = myObj;
    }
    else if (type == 2) {
        curDockWidget = new QDockWidget(title, parent);
        MyTitleBarWidget* titleBarWidget = new MyTitleBarWidget(curDockWidget);
        curDockWidget->setTitleBarWidget(titleBarWidget);
    }

    if (curDockWidget) {
        QWidget* mWidget = new QWidget(curDockWidget);
        QVBoxLayout* vLayout = new QVBoxLayout(mWidget);
        if (true) {
            QPlainTextEdit* pte = new QPlainTextEdit(mWidget);
            vLayout->addWidget(pte);
            //
            QString message = QString("%1, %2").arg(title, QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));
            pte->appendPlainText(message);
        }
        mWidget->setLayout(vLayout);
        //
        curDockWidget->setWidget(mWidget);
    }

    return curDockWidget;
}

void MainWindow::slotAddDockWidget()
{
    QString title; title.sprintf("index=%d, widgets=%d", m_widgetIndex + 1, m_widgets.size() + 1);
    QDockWidget* currDockWidget = createDockWidget(this, title, m_dockWidgetType);
    title.sprintf("第%d个页面", m_widgetIndex + 1);
    currDockWidget->setWindowTitle(title);
    currDockWidget->setAttribute(Qt::WA_DeleteOnClose, true);
    QObject::connect(currDockWidget, SIGNAL(destroyed(QObject*)), this, SLOT(slotDestroyed(QObject*)));
    this->addDockWidget(Qt::RightDockWidgetArea, currDockWidget);

    m_widgetIndex += 1;
    m_widgets[title] = currDockWidget;
}

void MainWindow::slotSetDockWidgetType()
{
    m_dockWidgetType = (m_dockWidgetType + 1) % 3;
    QString message = QString(tr("当前值=[%1]")).arg(m_dockWidgetType);
    QMessageBox::information(this, tr("设置DockWidget类型"), message);
}

void MainWindow::slotDestroyed(QObject *obj)
{
    QWidget* objWidget = qobject_cast<QWidget*>(obj);
    if (objWidget)
    {
        QString title = objWidget->windowTitle();
        auto it = m_widgets.find(title);
        if (m_widgets.end() != it)
        {
            m_widgets.erase(it);
        }
    }
    QDockWidget* objDockWidget = qobject_cast<QDockWidget*>(obj);//永远为0x0
    this->removeDockWidget(objDockWidget);
}
