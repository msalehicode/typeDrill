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
        settings.setValue("api_url","http://typedrill.ir/typedrill/api3/api.php");

    if(!settings.contains("username"))
        settings.setValue("username","");

    if(!settings.contains("session_key"))
        settings.setValue("session_key","");

    if (!settings.contains("theme"))
        settings.setValue("theme", "dark");

    if (!settings.contains("last_window_width"))
        settings.setValue("last_window_width", 700);

    if (!settings.contains("last_window_height"))
        settings.setValue("last_window_height", 700);

    if (!settings.contains("currentDatabase"))
        settings.setValue("currentDatabase", "practiceWord");

    if (!settings.contains("autoPlayAudioOnPractice"))
        settings.setValue("autoPlayAudioOnPractice", "true");
}
