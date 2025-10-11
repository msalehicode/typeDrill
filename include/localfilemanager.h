#ifndef LOCALFILEMANAGER_H
#define LOCALFILEMANAGER_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QFileInfo>
#include <QUrl>

class LocalFileManager : public QObject
{
    Q_OBJECT
    QString m_path;
public:
    explicit LocalFileManager(QObject *parent = nullptr);

    bool copyFile(const QString &sourcePath, QString destinationName);
    bool copyDirectory(const QString &sourceDir, const QString &destinationDir);
    bool removeFile(const QString &filePath);
    bool renameFile(const QString &oldName, const QString &newName);
    bool makeDirectory(QString dirName);
    QString extractFileName(const QString &fileUrl);
    QString extractFileExtension(const QString& fileUrl);
    bool isFileExist(QString filename);
    bool isFileExist(QString fpath, QString filename);
    QDateTime getLastModified(const QString& filePath);

    bool removeDirectoryAndContains(const QString &path,bool mpath=true);
    bool removeDirectoriesWithPrefix(const QString& prefix);

    bool renameDirectory(const QString& sourcePath, const QString& targetPath);

    qint64 getFileSize(const QString &fileName);
    QString getFilename(const QString& filePath);
    void setPath(const QString &newPath);



signals:
    // Signal to indicate success or failure of the copy operation
    void fileCopied(const QString &source, const QString &destination);
    void copyFailed(const QString &source, const QString &error);
    void fileRemoved(const QString &filePath);
    void removeFailed(const QString &filePath, const QString &error);
    void fileRenamed(const QString &oldName, const QString &newName);
    void renameFailed(const QString &oldName, const QString &error);
    void directoryCreated(const QString &dirPath);
    void createDirectoryFailed(const QString &dirPath, const QString &error);

private:
    bool copyFileInternal(const QString &sourcePath, const QString &destinationPath);
    bool copyDirectoryInternal(const QString &sourceDir, const QString &destinationDir);
};

#endif
