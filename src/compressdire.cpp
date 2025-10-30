#include "../include/compressdire.h"

void CompressDir::writeDirectory(QDataStream &out, const QDir &dir, const QString &basePath)
{
    QFileInfoList list = dir.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QFileInfo &info : list) {
        QString relativePath = QDir(basePath).relativeFilePath(info.absoluteFilePath());
        if (info.isDir()) {
            out << QString("DIR") << relativePath;
            writeDirectory(out, QDir(info.absoluteFilePath()), basePath);
        } else {
            QFile file(info.absoluteFilePath());
            if (file.open(QIODevice::ReadOnly)) {
                QByteArray fileData = file.readAll();
                out << QString("FILE") << relativePath << fileData;
            }
        }
    }
}

bool CompressDir::compressDirectory(const QString &dirPath, const QString &outFilePath)
{
    QDir dir(dirPath);
    if (!dir.exists()) return false;

    QByteArray buffer;
    QDataStream out(&buffer, QIODevice::WriteOnly);
    writeDirectory(out, dir, dir.absolutePath());

    QByteArray compressed = qCompress(buffer, 9);

    QFile outFile(outFilePath);
    if (!outFile.open(QIODevice::WriteOnly)) return false;
    outFile.write(compressed);
    outFile.close();
    return true;
}

bool CompressDir::decompressToDirectory(const QString &compressedFilePath, const QString &targetDirPath)
{
    QFile file(compressedFilePath);
    if (!file.open(QIODevice::ReadOnly)) return false;
    QByteArray compressed = file.readAll();
    QByteArray data = qUncompress(compressed);

    QDataStream in(data);

    QDir baseDir(targetDirPath);
    baseDir.mkpath(".");

    while (!in.atEnd()) {
        QString type;
        in >> type;
        if (type == "DIR") {
            QString relPath;
            in >> relPath;
            baseDir.mkpath(relPath);
        } else if (type == "FILE") {
            QString relPath;
            QByteArray fileData;
            in >> relPath >> fileData;
            QString fullPath = baseDir.filePath(relPath);
            QDir().mkpath(QFileInfo(fullPath).absolutePath());
            QFile outFile(fullPath);
            if (outFile.open(QIODevice::WriteOnly)) {
                outFile.write(fileData);
                outFile.close();
            }
        }
    }
    return true;
}
