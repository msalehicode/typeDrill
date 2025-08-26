#ifndef ANDROIDHELPER_H
#define ANDROIDHELPER_H

#include <QObject>
#include <QAndroidJniObject>
#include <jni.h>

class AndroidHelper : public QObject
{
    Q_OBJECT
public:
    explicit AndroidHelper(QObject *parent = nullptr);

    void setStatusBarColor(int color);
    void setNavigationBarColor(int color);
signals:
};

#endif // ANDROIDHELPER_H
