#include "androidcodes.h"

AndroidCodes::AndroidCodes() {}

void AndroidCodes::setSystemBarColors(const QColor &statusBarColor, const QColor &navigationBarColor)
{
    if (QOperatingSystemVersion::currentType() == QOperatingSystemVersion::Android) {
        // Convert QColor to Android ARGB int
        // Android expects color as 0xAARRGGBB
        auto toAndroidColor = [](const QColor &color) {
            return (color.alpha() << 24) |
                   (color.red() << 16) |
                   (color.green() << 8) |
                   (color.blue());
        };

        int statusColor = toAndroidColor(statusBarColor);
        int navColor = toAndroidColor(navigationBarColor);

        // Get current Qt Activity instance
        QAndroidJniObject activity = QtAndroid::androidActivity();

        // Get Window from activity
        QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");

        if (window.isValid()) {
            // Set status bar color
            window.callMethod<void>("setStatusBarColor", "(I)V", statusColor);

            // Set navigation bar color
            window.callMethod<void>("setNavigationBarColor", "(I)V", navColor);
        }
    }
}
