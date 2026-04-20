#ifndef BAMOZTTS_H
#define BAMOZTTS_H

#include <QObject>


#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QDebug>
#include <QRegularExpression>

#include <QNetworkRequest>
#include <QUrlQuery>


class BamozTTS : public QObject {
    Q_OBJECT

    QString m_savePath;
    QString m_saveFileName;
    QString m_filePath;
    bool saveFile(const QString& filePath, const QByteArray& data)
    {
        QFile file(filePath);
        if (file.open(QIODevice::WriteOnly))
        {
            file.write(data);
            file.close();
            qDebug() << "data saved to:" << filePath;
            return true;
        }
        else
            qWarning() << "Failed to save file.";
        return false;
    }
public:
    BamozTTS(QObject *parent = nullptr) : QObject(parent)
    {

    }

    void downloadTTS(const QString &text,const QString& path,
                     const QString& filename, const QString &lang = "en")
    {
        m_savePath=path;
        m_saveFileName=filename;

        QString baseUrl = QString("https://dic.b-amooz.com/%1/dictionary/w?word=%2").arg(lang).arg(text);

        QUrl url(baseUrl);

        QNetworkRequest request(url);
        request.setRawHeader("User-Agent", "Mozilla/5.0"); // Required

        qDebug() << "Requesting:" << url.toString();
        manager.get(request);
        connect(&manager, &QNetworkAccessManager::finished, this, &BamozTTS::onHtmlReply);
    }

signals:
    void ttsResult(bool result,const QString fname);

private slots:
    void onHtmlReply(QNetworkReply *reply)
    {
        if (reply->error() != QNetworkReply::NoError)
        {
            qWarning() << "Network error:" << reply->errorString();
            reply->deleteLater();
            disconnect(&manager, &QNetworkAccessManager::finished, this, &BamozTTS::onHtmlReply);
            emit ttsResult(false, "");
            return;
        }
        else
        {
            //------------- read chunk by chunk way
            // Use a QByteArray to accumulate data in chunks
            QByteArray receivedData;
            QByteArray buffer;
            QRegularExpression re("<small\\s+class=\\\"tts-readable\\\"\\s+data-url=\\\"([^\\\"]+)\\\"");
            QString ttsUrl = "";
            bool foundUrl = false;

            //avoid declare in loop
            QRegularExpressionMatch match;
            QString htmlChunk;
            int readCounter=0;
            const int maxRead=150;
            const int chunkBytes= 1024;
            // Loop to read data in chunks
            while (!reply->atEnd())
            {
                buffer = reply->read(chunkBytes); // Read up to 1024 bytes at a time
                receivedData.append(buffer);

                // Try to find the URL in the accumulated data
                htmlChunk = QString::fromUtf8(receivedData);
                match = re.match(htmlChunk);

                if (match.hasMatch()) {
                    ttsUrl = match.captured(1);
                    ttsUrl = ttsUrl.replace("&amp;", "&"); // unescape HTML entities
                    qDebug() << "Extracted TTS URL:" << ttsUrl;
                    foundUrl = true;
                    break; // Exit the loop once the URL is found
                }

                if(readCounter>maxRead) //maybe server went crazy and send infiite reply!
                    break;

                readCounter++;
            }

            qDebug() << "to find that TTS URL read " << readCounter << "*"<<chunkBytes << " bytes";

            reply->deleteLater();
            disconnect(&manager, &QNetworkAccessManager::finished, this, &BamozTTS::onHtmlReply);

            if (!foundUrl)
            {
                qDebug() << "Couldn't find TTS URL in the dictionary page.";
                emit ttsResult(false, "");
                return;
            }



            //try to dowonlad tts voice
            QNetworkReply *ttsReply = manager.get(QNetworkRequest(QUrl(ttsUrl)));

            //if tts voice loaded try to save it
            QObject::connect(ttsReply, &QNetworkReply::finished, [ttsReply,this]()
                             {
                                 if (ttsReply->error() != QNetworkReply::NoError)
                                 {
                                     qDebug() << "TTS download error:" << ttsReply->errorString();
                                     emit ttsResult(false, "");
                                     return;
                                 }

                                 QByteArray wavData = ttsReply->readAll();
                                 if(wavData.size()==0)
                                 {
                                     emit ttsResult(false,"");
                                 }
                                 else
                                 {

                                     m_filePath = m_savePath + m_saveFileName + ".wav";
                                     if(saveFile(m_filePath,wavData))
                                         emit ttsResult(true,m_filePath);
                                     else
                                         emit ttsResult(false,"");

                                 }

                                 ttsReply->deleteLater();
                                 disconnect(ttsReply, nullptr, this, nullptr);
                             });
        }

    }

private:
    QNetworkAccessManager manager;
};


#endif // BAMOZTTS_H
