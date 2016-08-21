//  DownloadService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

let identifier: String = "group.com.bitbucket.benmoussa.islam.quranpro"
typealias CompleteHandlerBlock = () -> ()

enum MirrorIndex : Int {
    case ERROR = -1
    case ABM
    case PMA
    case IH1
    case IH2
}


class DownloadService: NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    // Singlton instance
    class var instance: DownloadService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DownloadService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DownloadService()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
        }
        return Static.instance!
    }
    
    //var mirrors: Array<String?> = [String?](count:4, repeatedValue: nil)
    var handlerQueue: [String : CompleteHandlerBlock]!
    var session: NSURLSession!
    var sessionConfiguration: NSURLSessionConfiguration!

    override init(){
        super.init()
        self.sessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        self.sessionConfiguration.HTTPMaximumConnectionsPerHost = 5
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        if let handler : CompleteHandlerBlock = handlerQueue[identifier]{
            handlerQueue!.removeValueForKey(identifier)
            handler()
        }
    }
    
    
    func getAudioChapterWithTaskIdentifier(taskIdentifier: Int) -> AudioChapter?{
        for  chapter in $.currentReciter.audioChapters {
            if chapter.taskIdentifier == taskIdentifier {
                return chapter
            }
        }
        return nil
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("session error: \(error?.localizedDescription).")
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
        
        if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(downloadTask.taskIdentifier) {
            let fm: NSFileManager = NSFileManager.defaultManager()
            
            if fm.fileExistsAtPath(audiChapter.downloadLocation) {
                do {
                    try fm.removeItemAtPath(audiChapter.downloadLocation)
                } catch _ {
                }
            }
            
            //print(audiChapter.downloadFolder)
            // when expanding the zip file, the chapter filder name will be automaticatly created
            if SSZipArchive.unzipFileAtPath(location.path, toDestination: audiChapter.downloadFolder) {
                
                // Change the flag values of the respective audiChapter object.
                audiChapter.isDownloading = false
                
                // Set the initial value to the taskIdentifier property of the fdi object,
                // so when the start button gets tapped again to start over the file download.
                audiChapter.taskIdentifier = -1
                
                // In case there is any resume data stored in the fdi object, just make it nil.
                audiChapter.taskResumeData = nil
                
                audiChapter.isRetrying = false
                
                // Notify the ui about those changes
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    NSNotificationCenter.defaultCenter().postNotificationName(kDownloadCompleteNotification, object: nil,  userInfo:["audiChapter": audiChapter])
                })

                do {
                    // remove the temp file
                    try fm.removeItemAtPath(location.path!)
                } catch _ {
                }
            }
            else{
                // Something went wrong, it seems the file couldn't be downloaded from the mirror
                // Notify the ui about those changes
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    NSNotificationCenter.defaultCenter().postNotificationName(kDownloadErrorNotification, object: nil,  userInfo:["audiChapter": audiChapter])
                })
            }
            
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
        
        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
//            println("Unknown transfer size");
        }
        else{
            // locate the audio chapter being downloaded based on the task indentifier 
            if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(downloadTask.taskIdentifier) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    // Calculate the progress.
                    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    if Int(progress  * 100) != 100 {
                        audiChapter.downloadProgress = progress
                        NSNotificationCenter.defaultCenter().postNotificationName(kProgressUpdatedNotification, object: nil,  userInfo:["audiChapter": audiChapter])
                    }
                })
            }
        }
    }
    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
            print("session \(session) download completed")
            
            /*
            if !session.configuration.identifier!.isEmpty {
                callCompletionHandlerForSession(session.configuration.identifier)
            }
            
            session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
                if downloadTasks.count == 0 /*!self.hasPendingTasks(downloadTasks)*/ {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        let localNotification = UILocalNotification()
                        localNotification.alertBody = "All audios have been downloaded!".local;
                        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                    })
                }
            }
    */
        } else {
            print("session \(session) download failed with error \(error?.localizedDescription)")
            if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(task.taskIdentifier) {
                // Something went wrong, it seems the file couldn't be downloaded from the mirror
                // Notify the ui about those changes
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    NSNotificationCenter.defaultCenter().postNotificationName(kDownloadErrorNotification, object: nil,  userInfo:["audiChapter": audiChapter])
                })
            }
        }
    }
    
//    func hasPendingTasks(downloadTasks: [NSURLSessionDownloadTask])-> Bool {
//        var output: Bool = false
//        for task in downloadTasks {
//            if task.state != .Completed {
//                output = true
//                break
//            }
//        }
//        return output
//    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("background session \(session) finished events.")
        
//        if !session.configuration.identifier!.isEmpty {
//            callCompletionHandlerForSession(session.configuration.identifier)
//        }
//        
//        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
//            if downloadTasks.count == 0 {
//                NSOperationQueue.mainQueue().addOperationWithBlock({
//                    let localNotification = UILocalNotification()
//                    localNotification.alertBody = "All audios have been downloaded!".local;
//                    UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
//                })
//            }
//        }
    }
}

class PlistDownloader {
    //http://stackoverflow.com/questions/30722971/swift-datataskwithrequest-completion-block-not-executed
    
    class func load(url: String, finished:(NSObject)->(), fault:(NSError)->()) {
        let dest = NSURL(string: url)
        let request = NSURLRequest(URL: dest!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if(error != nil){
                fault(error!)
            }
            else{
                let v:NSArray?
                do {
                    v = try NSPropertyListSerialization.propertyListWithData(data!, options: NSPropertyListReadOptions.Immutable, format: nil) as? NSArray
                    finished(v!)
                } catch  {
                    v = nil
                }
            }
        }
        task.resume()
    }
}

// Simplfy the data manager call to the $$ sign
var DS: DownloadService = DownloadService.instance

