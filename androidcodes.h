#ifndef ANDROIDCODES_H
#define ANDROIDCODES_H

#include <QObject>
#include <QAndroidJniObject>
#include <QtAndroid>


class AndroidCodes
{
public:
    AndroidCodes();
private:
    void setSystemBarColors(const QColor &statusBarColor, const QColor &navigationBarColor);
};

#endif // ANDROIDCODES_H
