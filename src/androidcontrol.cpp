#include "../include/androidcontrol.h"

AndroidControl::AndroidControl(QObject *parent)
    : QObject{parent}
{}

void AndroidControl::setStatusBarColor(int r, int g, int b)
{
#ifdef Q_OS_ANDROID
    QJniObject activity =
        QJniObject::callStaticObjectMethod(
            "org/qtproject/qt/android/QtNative",
            "activity",
            "()Landroid/app/Activity;"
            );

    if (!activity.isValid())
        return;

    QJniObject window =
        activity.callObjectMethod(
            "getWindow",
            "()Landroid/view/Window;"
            );

    const int FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS = 0x80000000;
    window.callMethod<void>("addFlags", "(I)V",
                            FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);

    int color = (0xFF << 24) | (r << 16) | (g << 8) | b;
    window.callMethod<void>("setStatusBarColor", "(I)V", color);
#endif
}

void AndroidControl::setNavigationBarColor(int r, int g, int b)
{
#ifdef Q_OS_ANDROID
    QJniObject activity =
        QJniObject::callStaticObjectMethod(
            "org/qtproject/qt/android/QtNative",
            "activity",
            "()Landroid/app/Activity;"
            );

    if (!activity.isValid())
        return;

    QJniObject window =
        activity.callObjectMethod(
            "getWindow",
            "()Landroid/view/Window;"
            );

    const int FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS = 0x80000000;
    window.callMethod<void>("addFlags", "(I)V",
                            FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);

    int color = (0xFF << 24) | (r << 16) | (g << 8) | b;

    window.callMethod<void>(
        "setNavigationBarColor",
        "(I)V",
        color
        );
#endif
}

void AndroidControl::hideNavigationBar()
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;"
        );

    if (!activity.isValid())
        return;

    QJniObject window = activity.callObjectMethod(
        "getWindow",
        "()Landroid/view/Window;"
        );

    if (!window.isValid())
        return;

    // Try modern API (Android 11+)
    QJniObject insetsController = window.callObjectMethod(
        "getInsetsController",
        "()Landroid/view/WindowInsetsController;"
        );

    if (insetsController.isValid()) {
        // WindowInsets.Type.navigationBars()
        jint navBarsType = QJniObject::callStaticMethod<jint>(
            "android/view/WindowInsets$Type",
            "navigationBars",
            "()I"
            );

        insetsController.callMethod<void>(
            "hide",
            "(I)V",
            navBarsType
            );
        return;
    }

    // Fallback for older Android versions
    QJniObject decorView = window.callObjectMethod(
        "getDecorView",
        "()Landroid/view/View;"
        );

    if (!decorView.isValid())
        return;

    const int SYSTEM_UI_FLAG_HIDE_NAVIGATION = 0x2;
    const int SYSTEM_UI_FLAG_IMMERSIVE_STICKY = 0x1000;

    int flags = SYSTEM_UI_FLAG_HIDE_NAVIGATION | SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
    decorView.callMethod<void>("setSystemUiVisibility", "(I)V", flags);
#endif
}

