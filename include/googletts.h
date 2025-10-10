#ifndef GOOGLETTS_H
#define GOOGLETTS_H

#include <QObject>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QUrlQuery>
#include <QStandardPaths>
#include <QDebug>

class GoogleTTS : public QObject {
    Q_OBJECT

    QString savePath;
    QString saveFileName;
public:
    GoogleTTS(QObject *parent = nullptr) : QObject(parent) {
        connect(&manager, &QNetworkAccessManager::finished, this, &GoogleTTS::onReplyTTS);
    }

    void downloadTTS(const QString &text,const QString& path,
                     const QString& filename, const QString &lang = "en")
    {
        savePath=path;
        saveFileName=filename;

        QString baseUrl = "http://translate.google.com/translate_tts";

        QUrl url(baseUrl);
        QUrlQuery query;
        query.addQueryItem("ie", "UTF-8");
        query.addQueryItem("q", text);
        query.addQueryItem("tl", lang);
        query.addQueryItem("client", "tw-ob");

        url.setQuery(query);

        QNetworkRequest request(url);
        request.setRawHeader("User-Agent", "Mozilla/5.0"); // Required

        qDebug() << "Requesting:" << url.toString();
        manager.get(request);
    }

signals:
    void ttsResult(const bool& result,const QString fname);

private slots:
    void onReplyTTS(QNetworkReply *reply)
    {
        bool result=false;
        if (reply->error() != QNetworkReply::NoError)
        {
            qWarning() << "Network error:" << reply->errorString();
        }
        else
        {
            QByteArray data = reply->readAll();
            QString filePath = savePath + saveFileName + ".mp3";

            QFile file(filePath);
            if (file.open(QIODevice::WriteOnly))
            {
                file.write(data);
                file.close();
                qDebug() << "MP3 saved to:" << filePath;
                result=true;
            }
            else
            {
                qWarning() << "Failed to save file.";
            }
        }


        reply->deleteLater();
        emit ttsResult(result,saveFileName+".mp3");
    }

private:
    QNetworkAccessManager manager;
};


#endif // GOOGLETTS_H
