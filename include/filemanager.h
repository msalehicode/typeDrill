#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QStandardPaths>
#include <QDir>

//upload
#include <QHttpMultiPart>
#include <QHttpPart>


class FileManager : public QObject {
    Q_OBJECT
public:
    explicit FileManager(QObject *parent = nullptr);

    Q_INVOKABLE void downloadFile(const QString &url, const QString &fileName);
    Q_INVOKABLE void uploadFile(const QString &uploadUrl, const QString &filePath, const QString &apiKey, const QString& publicStatus);

signals:
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished(bool success, const QString &filePath);
    void uploadFinished(bool success, const QString& resultUpload);

private slots:
    void onDownloadFinished();
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);

private:
    QNetworkAccessManager m_manager;
    QNetworkReply *m_currentReply = nullptr;
    QFile m_outputFile;
};

#endif // FILEMANAGER_H
