#include "../include/settingsmanager.h"

SettingsManager::SettingsManager(QObject *parent)
    : QObject{parent}
{

}

void SettingsManager::setValue(const QString &key, const QVariant &value)
{
    settings.setValue(key, value);
}

QVariant SettingsManager::getValue(const QString &key, const QVariant &defaultValue)
{
    return settings.value(key, defaultValue);
}

void SettingsManager::remove(const QString &key) {
    settings.remove(key);
}

void SettingsManager::initSettings()
{
    if(!settings.contains("api_url"))
        settings.setValue("api_url","http://typedrill.ir/typedrill/api/api.php");

    if(!settings.contains("api_key"))
        settings.setValue("api_key","YOUR_SECRET_API_KEY");

    if (!settings.contains("theme"))
        settings.setValue("theme", "dark");

    if (!settings.contains("last_window_width"))
        settings.setValue("last_window_width", 700);

    if (!settings.contains("last_window_height"))
        settings.setValue("last_window_height", 700);

    if (!settings.contains("currentDatabase"))
        settings.setValue("currentDatabase", "practiceWord");
}
