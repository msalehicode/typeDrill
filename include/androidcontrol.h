#ifndef ANDROIDCONTROL_H
#define ANDROIDCONTROL_H

#include <QObject>

#ifdef Q_OS_ANDROID
#include <QJniObject>
#endif

class AndroidControl : public QObject
{
    Q_OBJECT
public:
    explicit AndroidControl(QObject *parent = nullptr);

    void setStatusBarColor(int r, int g, int b);
    void setNavigationBarColor(int r, int g, int b);
    void hideNavigationBar();

signals:
};

#endif // ANDROIDCONTROL_H
