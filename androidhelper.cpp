#include "androidhelper.h"

AndroidHelper::AndroidHelper(QObject *parent)
    : QObject{parent}
{}

void AndroidHelper::setStatusBarColor(int color)
{
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;"
        );
    if (!activity.isValid())
        return;

    QAndroidJniObject window = activity.callObjectMethod(
        "getWindow",
        "()Landroid/view/Window;"
        );
    if (!window.isValid())
        return;

    window.callMethod<void>("setStatusBarColor", "(I)V", color);
}

void AndroidHelper::setNavigationBarColor(int color)
{
    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;"
        );
    if (!activity.isValid())
        return;

    QAndroidJniObject window = activity.callObjectMethod(
        "getWindow",
        "()Landroid/view/Window;"
        );
    if (!window.isValid())
        return;

    window.callMethod<void>("setNavigationBarColor", "(I)V", color);
}
