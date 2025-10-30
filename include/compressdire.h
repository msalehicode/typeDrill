#ifndef COMPRESSDIR_H
#define COMPRESSDIR_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QDataStream>
#include <QByteArray>
#include <QDebug>

class CompressDir : public QObject
{
    Q_OBJECT
public:
    explicit CompressDir(QObject *parent = nullptr) : QObject(parent) {}

    // Compress a directory into a single file
    bool compressDirectory(const QString &dirPath, const QString &outFilePath);

    // Decompress a file into a directory
    bool decompressToDirectory(const QString &compressedFilePath, const QString &targetDirPath);

private:
    void writeDirectory(QDataStream &out, const QDir &dir, const QString &basePath);
};

#endif // COMPRESSDIR_H
