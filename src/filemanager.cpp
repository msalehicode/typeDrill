#include "../include/filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent) {}

void FileManager::downloadFile(const QString &url, const QString &fileName, bool overwriteFilename)
{
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

    if(!overwriteFilename) //add something to filename
    {
        while (QFile::exists(dir.filePath(uniqueFileName)))
        {
            uniqueFileName = QString("%1_%2%3").arg(baseName).arg(counter).arg(extension);
            counter++;
        }
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

void FileManager::uploadFile(const QString &uploadUrl, const QString &filePath,
                             const QString &apiKey, const QString& publicStatus,
                             QString requestType,
                             const QString& fileLastModified)
{
    QFile *file = new QFile(filePath);
    if (!file->open(QIODevice::ReadOnly)) {
        emit uploadFinished(false, "Failed to open file for upload");
        delete file;
        return;
    }

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // File part
    QHttpPart filePart;
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                       QVariant("form-data; name=\"file\"; filename=\"" + QFileInfo(filePath).fileName() + "\""));
    filePart.setBodyDevice(file);
    file->setParent(multiPart); // so it will be deleted with multiPart
    multiPart->append(filePart);

    // Status part (if you need it)
    if (!publicStatus.isEmpty())
    {
        QHttpPart statusPart;
        statusPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"status\""));
        statusPart.setBody(publicStatus.toUtf8());
        multiPart->append(statusPart);
    }

    // Request type (as form data)
    QHttpPart requestPart;
    requestPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"request\""));
    requestPart.setBody("upload-db"); // This is the value you were setting in the header
    multiPart->append(requestPart);

    // Session key (as form data)
    QHttpPart sessionKeyPart;
    sessionKeyPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"sessionKey\""));
    sessionKeyPart.setBody(apiKey.toUtf8()); // Send the session key in form data
    multiPart->append(sessionKeyPart);

    // Create the network request (no need to set sessionKey in headers anymore)
    QNetworkRequest request(uploadUrl);

    // Set raw headers (this is where sessionKey and requestType should go)
    request.setRawHeader("sessionKey", apiKey.toUtf8());
    request.setRawHeader("request", requestType.toUtf8());

    request.setRawHeader("lmdate", fileLastModified.toUtf8());

    request.setRawHeader("status", publicStatus.toUtf8()); // Send request as a header


    // Send the request
    QNetworkReply *reply = m_manager.post(request, multiPart);
    multiPart->setParent(reply); // delete with reply

    // Handle the reply
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            {
                if (reply->error() == QNetworkReply::NoError)
                {
                    QByteArray response = reply->readAll();

                    //message/error parse
                    QString resultMessage;
                    QString resultError;
                    QJsonDocument doc = QJsonDocument::fromJson(response);
                    // Check if the document is an array or an object
                    if (doc.isArray())
                    {
                        // Handle JSON array
                        QJsonArray arr = doc.array();
                        for (const auto &item : arr)
                        {
                            if (item.isObject())
                            {
                                QJsonObject obj = item.toObject();
                                resultError = obj["error"].toString();
                                resultMessage = obj["message"].toString();
                                qInfo() << "array= resultError=" << resultError << "resultMessage"  << resultMessage;
                            }
                            else
                            {
                                qInfo() << "Array item is not a valid object";
                                resultError = "Array item is not a valid object";
                            }
                        }
                    }
                    else if (doc.isObject())
                    {
                        // Handle JSON object
                        QJsonObject obj = doc.object();
                        resultError = obj["error"].toString();
                        resultMessage = obj["message"].toString();
                        qInfo() << "obj= resultError=" << resultError << "resultMessage"  << resultMessage;
                    }
                    else
                    {
                        // Handle unexpected JSON format
                        qInfo() << "Unexpected response format: Neither an object nor an array.";
                        resultError = "Unexpected response format";
                    }

                    emit uploadFinished(true, resultError.isEmpty() ? resultMessage : resultError);
                }
                else
                {
                    emit uploadFinished(false, QString("Upload failed: %1").arg(reply->errorString()));
                }

                reply->deleteLater();
            });
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
