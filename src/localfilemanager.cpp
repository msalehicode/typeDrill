#include "include/localfilemanager.h"
#include <QFile>
#include <QDir>
#include <QFileInfo>

void LocalFileManager::setPath(const QString &newPath)
{
    m_path = newPath + "/";
}

LocalFileManager::LocalFileManager(QObject *parent)
    : QObject(parent)
{
}

bool LocalFileManager::copyFile(const QString &sourceUrl, QString destinationName)
{
    destinationName = m_path + destinationName;
    // Convert the file URL to a local path
    QUrl sourceQUrl(sourceUrl);
    QString localSourcePath = sourceQUrl.toLocalFile();

    // Check if the source file exists
    QFile sourceFile(localSourcePath);
    if (!sourceFile.exists())
    {
        emit copyFailed(sourceUrl, "Source file does not exist.");
        return false;
    }

    // Perform the copy operation
    if (copyFileInternal(localSourcePath, destinationName)) {
        emit fileCopied(sourceUrl, destinationName);
        return true;
    } else {
        emit copyFailed(sourceUrl, "File copy failed.");
        return false;
    }
}


bool LocalFileManager::copyDirectory(const QString &sourceDir, const QString &destinationDir)
{
    QDir sourceDirectory(sourceDir);
    if (!sourceDirectory.exists()) {
        emit copyFailed(sourceDir, "Source directory does not exist.");
        return false;
    }

    QDir destinationDirectory(destinationDir);
    if (!destinationDirectory.exists() && !destinationDirectory.mkpath(destinationDir)) {
        emit copyFailed(sourceDir, "Unable to create destination directory.");
        return false;
    }

    if (copyDirectoryInternal(sourceDir, destinationDir)) {
        emit fileCopied(sourceDir, destinationDir);
        return true;
    } else {
        emit copyFailed(sourceDir, "Directory copy failed.");
        return false;
    }
}

bool LocalFileManager::removeFile(const QString &filePath)
{
    QString path = m_path + filePath;
    QFile file(path);
    if (file.exists())
    {
        if (file.remove())
        {
            return true;
        }
        else
        {
            qInfo() << path << "Failed to remove the file.";
            return false;
        }
    }
    else
    {
        qInfo() << path << "remove: File does not exist.";
        return false;
    }
}

bool LocalFileManager::renameFile(const QString &oldName, const QString &newName)
{
    QFile file(oldName);
    if (file.exists()) {
        if (file.rename(newName)) {
            emit fileRenamed(oldName, newName);
            return true;
        } else {
            emit renameFailed(oldName, "Failed to rename the file.");
            return false;
        }
    } else {
        emit renameFailed(oldName, "File does not exist.");
        return false;
    }
}

QString LocalFileManager::extractFileName(const QString &fileUrl)
{
    // Convert the URL to a QUrl object
    QUrl url(fileUrl);

    // Check if the URL is valid and points to a file
    if (url.isValid() && url.scheme() == "file")
    {
        // Extract the local path from the URL
        QString localPath = url.toLocalFile();

        // Use QFileInfo to extract the file name from the path
        QFileInfo fileInfo(localPath);

        // Return just the file name (without the path)
        return fileInfo.fileName();
    }

    // If the URL is invalid or not a file URL, return an empty string
    return QString();
}

QString LocalFileManager::extractFileExtension(const QString &fileUrl)
{
    // Convert the URL to a QUrl object
    QUrl url(fileUrl);

    // Check if the URL is valid and points to a file
    if (url.isValid() && url.scheme() == "file")
    {
        // Extract the local path from the URL
        QString localPath = url.toLocalFile();

        // Use QFileInfo to extract the file extension from the path
        QFileInfo fileInfo(localPath);

        // Return the file extension (without the dot)
        return fileInfo.suffix();
    }

    // If the URL is invalid or not a file URL, return an empty string
    return QString();
}

bool LocalFileManager::isFileExist(QString filename)
{
    filename = m_path + filename;
    QFile file(filename);
    if (file.exists())
        return true;
    return false;
}

bool LocalFileManager::isFileExist(QString fpath, QString filename)
{
    fpath = fpath + filename;
    QFile file(fpath);
    if (file.exists())
        return true;

    return false;
}

QDateTime LocalFileManager::getLastModified(const QString &filePath)
{
    QFileInfo fileInfo(filePath);

    if (fileInfo.exists())
    {
        QDateTime lastModified = fileInfo.lastModified();
        qDebug() << "Last modified:" << lastModified.toString();
        return lastModified;
    }
    else
    {
        qDebug() << "File does not exist.";
        return QDateTime(); // Return invalid/empty QDateTime
    }
}


qint64 LocalFileManager::getFileSize(const QString &fileName)
{
    // Convert the QUrl to a local file path
    // QString filePath = fileName.toLocalFile();
    QString filePath = m_path + fileName;


    QFileInfo fileInfo(filePath);

    // Check if the file exists and is a valid file
    if (!fileInfo.exists() || !fileInfo.isFile())
    {
        qInfo() << "File does not exist or is not a regular file.";
        return -1;
    }

    // Return the size of the file in bytes
    return fileInfo.size();
}

QString LocalFileManager::getFilename(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    return fileInfo.fileName();
}


bool LocalFileManager::makeDirectory(QString dirName)
{
    QDir dir;
    if (dir.exists(m_path+dirName))
    {
        emit createDirectoryFailed(m_path+dirName, "Directory already exists.");
        return false;
    }

    if (dir.mkpath(m_path+dirName))
    {
        emit directoryCreated(m_path+dirName);
        return true;
    }
    else
    {
        emit createDirectoryFailed(m_path+dirName, "Failed to create the directory.");
        return false;
    }
}

bool LocalFileManager::copyFileInternal(const QString &sourcePath, const QString &destinationPath)
{
    QFile sourceFile(sourcePath);
    if (sourceFile.copy(destinationPath)) {
        return true;
    }
    return false;
}

bool LocalFileManager::copyDirectoryInternal(const QString &sourceDir, const QString &destinationDir)
{
    QDir sourceDirectory(sourceDir);
    QDir destinationDirectory(destinationDir);

    QFileInfoList entries = sourceDirectory.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);

    foreach (const QFileInfo &entry, entries) {
        QString sourcePath = entry.absoluteFilePath();
        QString destinationPath = destinationDir + "/" + entry.fileName();

        if (entry.isDir()) {
            if (!copyDirectoryInternal(sourcePath, destinationPath)) {
                return false;
            }
        } else {
            if (!copyFileInternal(sourcePath, destinationPath)) {
                return false;
            }
        }
    }

    return true;
}
