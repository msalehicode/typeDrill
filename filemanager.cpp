#include "filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent) {}

void FileManager::downloadFile(const QString &url, const QString &fileName) {
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }
    // Construct path where to save the file
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    // Ensure directory exists
    QDir dir(appDataPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    // Find unique filename (adds _1, _2... if needed)
    QString baseName = QFileInfo(fileName).completeBaseName();
    QString extension = QFileInfo(fileName).suffix();
    QString uniqueFileName = fileName;
    int counter = 1;

    while (QFile::exists(dir.filePath(uniqueFileName))) {
        uniqueFileName = QString("%1_%2.%3").arg(baseName).arg(counter).arg(extension);
        counter++;
    }

    QString savePath = dir.filePath(uniqueFileName);


    if (m_outputFile.isOpen()) {
        m_outputFile.close();
    }
    m_outputFile.setFileName(savePath);
    if (!m_outputFile.open(QIODevice::WriteOnly)) {
        emit downloadFinished(false, savePath);
        return;
    }


    QNetworkRequest request(url);
    m_currentReply = m_manager.get(request);

    connect(m_currentReply, &QNetworkReply::finished, this, &FileManager::onDownloadFinished);
    connect(m_currentReply, &QNetworkReply::downloadProgress, this, &FileManager::onDownloadProgress);
}

void FileManager::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal) {
    emit downloadProgress(bytesReceived, bytesTotal);
}

void FileManager::onDownloadFinished() {
    if (!m_currentReply)
        return;

    if (m_currentReply->error() == QNetworkReply::NoError) {
        m_outputFile.write(m_currentReply->readAll());
        m_outputFile.close();
        emit downloadFinished(true, m_outputFile.fileName());
    } else {
        m_outputFile.close();
        m_outputFile.remove();
        emit downloadFinished(false, m_outputFile.fileName());
    }
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
}
