#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QStandardPaths>
#include <QDir>

class FileManager : public QObject {
    Q_OBJECT
public:
    explicit FileManager(QObject *parent = nullptr);

    Q_INVOKABLE void downloadFile(const QString &url, const QString &fileName);

signals:
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished(bool success, const QString &filePath);

private slots:
    void onDownloadFinished();
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    QNetworkAccessManager m_manager;
    QNetworkReply *m_currentReply = nullptr;
    QFile m_outputFile;
};

#endif // FILEMANAGER_H
