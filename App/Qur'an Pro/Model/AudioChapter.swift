//
//  AudioChapter.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class AudioChapter: CustomStringConvertible {
    
    // chapter id
    var id: Int
    // reciter id
    var parent: Reciter
    // chapter file name
    var fileName: String
    var folderName: String
    // the file size
    var size: Int64
    //A NSURLSessionDownloadTask object that will be used to keep a strong reference to the download task of a file.
    var downloadTask: NSURLSessionDownloadTask?
    //A NSData object that keeps the data produced by a cancelled download task that can be resumed at a later time (in other words, when it’s paused).
    var taskResumeData: NSData?
    //The download progress of a file as reported by the NSURLSession delegate methods.
    var downloadProgress: Float
    //This flag, as its name suggests, indicates whether a file is being downloaded or not.
    var isDownloading: Bool
    //When a download task is initiated, the NSURLSession assigns it a unique identifier so it can be distinguished among others. The identifier values start from 0. In this property, we will assign the task identifier value of the downloadTask property (even though the downloadTask object has its own taskIdentifier property) just for our own convenience during implementation.
    var taskIdentifier: Int?
    var failedCount: Int!
    var special: Bool
    // Flag indicating whether the download was puased or not
    var downloadPaused: Bool
    // Flag indicating whether the download action is retrying
    var isRetrying: Bool
    
    //init the class model
    init(id: Int, parent: Reciter, fileName: String, size: Int64){
        self.id = id
        self.parent = parent
        self.fileName = fileName
        self.size = size
        self.downloadProgress = 0
        self.isDownloading = false
        self.taskIdentifier = -1
        self.failedCount = 0
        self.downloadPaused = false
        self.special = kSpecialReciterFolderFormatIds.contains(self.parent.id)
        self.folderName = self.fileName.stringByDeletingPathExtension
        self.isRetrying = false
    }
    
    // Check weather
    var isDownloaded: Bool {
        let firstVersePath: String = downloadFolder + firstVerseAudioName
        return NSFileManager.defaultManager().fileExistsAtPath(firstVersePath)
    }
    
    // display the size in an human format
    var sizeDisplay: String {
        let formatter = NSByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        return formatter.stringFromByteCount(size)
    }
    
    private var firstVerseAudioName: String {
        return special ? "000.mp3" :  "\(folderName)/\(folderName)000.mp3"
    }
    
    // download location
    var downloadLocation: String {
        return "\(downloadFolder)\(fileName)/"
    }
    
    var downloadFolder: String {
        return special ? reciterFolder + folderName + "/" : reciterFolder
    }
    
    var reciterFolder: String {
        return "\(NSBundle.documents())/audios/\(parent.id)/"
    }
    
    var description: String {
        return "id= \(id), reciterId= \(parent.id), fileName= \(fileName), size= \(size),isDownloading= \(isDownloading), isDownloaded= \(isDownloaded), downloadFolder= \(downloadFolder)"
    }
    
    //
    func verseAudioPath(verse: Verse) -> String {
        if special == true{
            if verse.id == -1 {
                return NSBundle.mainBundle().pathForResource("basmala_\(parent.id)_001000", ofType: "mp3")!
            }
            else{
                return downloadFolder + verse.fileNameForSpecialReciterFolder
            }
        }
        else{
            return downloadFolder + folderName + "/" + folderName + verse.fileName
        }
    }
    
    func reset(){
        self.downloadTask?.cancel()
        self.downloadProgress = 0
        self.isDownloading = false
        self.taskIdentifier = -1
        self.failedCount = 0
        self.taskResumeData = nil
        self.downloadPaused = false
        self.isRetrying = false
    }
}