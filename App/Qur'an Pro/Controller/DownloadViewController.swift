//
//  DownloadViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
// Copyright (c) 2015 Islamhome.info. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var downloadAllButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var reciter: Reciter!
    var cancelAll: Bool!
    var multipleDownload: Bool!
    var errorWasShown: Bool!
    var firstNotDownloadedAudioChapter: AudioChapter?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
        overrideBackButton()
        downloadAllButton.enabled = !isDownloading() && isPro
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Download".local
        reciter = $.currentReciter
        cancelAll = false
        multipleDownload = false
        firstNotDownloadedAudioChapter = nil
        errorWasShown = false
    }
    
    func registerNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressUpdatedHandler:", name:kProgressUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downloadCompleteHandler:", name:kDownloadCompleteNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downloadErrorHandler:", name:kDownloadErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downloadStartedHandler:", name:kDownloadStartedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downloadDeadHandler:", name:kDownloadDeadNotification, object: nil)
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reciter.audioChapters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DownloadCellIdentifier") as! DownloadCell
        let audioChapter:AudioChapter = reciter.audioChapters[indexPath.row] as AudioChapter
        let chapter:Chapter = $.chapters[indexPath.row] as Chapter
        cell.chapterName!.text = "\(chapter.id + 1). \(chapter.name.local)"
        cell.downloadState!.text = audioChapter.isDownloaded ? "Downloaded ✅".local.uppercaseString : "Download".local.uppercaseString
        cell.downloadState!.textColor = audioChapter.isDownloaded ? kAppColor :  kCellTextLabelColor
        cell.downloadState.font = audioChapter.isDownloaded ? kDownloadedFont : kDownloadFont
        cell.downlaodSize!.text = audioChapter.sizeDisplay
        
        // Depending on whether the current file is being downloaded or not, specify the status
        // of the progress bar and the couple of buttons on the cell.
        if (!audioChapter.isDownloaded && (audioChapter.isDownloading || audioChapter.downloadPaused || audioChapter.isRetrying)) {
            // Show the progress view and update its progress, change the image of the start button so it shows
            // a pause icon, and enable the stop button.
            cell.downloadPercentage.hidden = false
            cell.progressView.hidden = false
            cell.downloadState.hidden = true
            cell.downlaodSize.hidden = true
            cell.progressView.progress = CGFloat(audioChapter.downloadProgress)
            cell.downloadPercentage.text = "\(Int(audioChapter.downloadProgress  * 100))%"
            if !isPro {
                if chapter.id != 0 && chapter.id != 1 {
                    cell.lock()
                }
                else{
                    cell.unlock()
                }
            }
            
        }
        else {
            cell.progressView.hidden = true
            cell.downloadPercentage.hidden = true
            cell.downloadState.hidden = false
            cell.downlaodSize.hidden = false
            if !isPro {
                if chapter.id != 0 && chapter.id != 1 {
                    cell.lock()
                }
                else{
                    cell.unlock()
                }
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kHeightForRowAtIndexPath
    }
    
    // Mark: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: DownloadCell  = tableView.cellForRowAtIndexPath(indexPath) as! DownloadCell
        let audioChapter:AudioChapter = reciter.audioChapters[indexPath.row] as AudioChapter
        func didSelectHandler() {
            cell.contentView.backgroundColor = kSelectedCellBackgroudColor
            // Do nothing the the audio if it is already downloaded
            if !multipleDownload && !audioChapter.isDownloaded && !audioChapter.isDownloading {
                self.startDownload(audioChapter, handler: { (Void) -> Void in
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
            }
            else if audioChapter.isDownloaded  || audioChapter.isDownloading {
                createActionSheet(audioChapter, cell: cell)
            }
        }
        if isPro {
            didSelectHandler()
        }
        else{
            if audioChapter.id == 0 || audioChapter.id == 1 {
                didSelectHandler()
            }
            else{
                self.askUserForPurchasingProVersion(FlurryEvent.downloadFromRow)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func startFirstOfAllDownloadsNow(){
        cancelAll = false
        multipleDownload = true
        // first download the first element of the array
        // in order be sure that we are dealing with the correct url
        firstNotDownloadedAudioChapter = getNextAudioChapterToDownload()
        if firstNotDownloadedAudioChapter != nil {
            // Disable the download all button
            downloadAllButton.enabled = false
            startDownloadNow(firstNotDownloadedAudioChapter!)
        }
    }
    
    func startAllDownloadsNow() {
        var i:Int = 0
        // Access the first 10  AudioChapter objects using a loop.
        for audioChapter in reciter.audioChapters {
            
            // Check if a file is already being downloaded or not.
            if !audioChapter.isDownloaded && !audioChapter.isDownloading {
                // Check if should create a new download task using a URL, or using resume data.
                if audioChapter.taskIdentifier == -1 || audioChapter.taskResumeData == nil {
                    //audioChapter.
                    urlRequest(audioChapter, resultHandler: { request in
                        if request != nil {
                            audioChapter.downloadTask = DS.session.downloadTaskWithRequest(request!)
                            audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier
                            
                            // Start the task.
                            audioChapter.downloadTask?.resume()
                            // Indicate for each file that is being downloaded.
                            audioChapter.isDownloading = true
                            audioChapter.downloadPaused = false
                            NSNotificationCenter.defaultCenter().postNotificationName(kDownloadStartedNotification, object: nil,  userInfo:["audiChapter": audioChapter])
                            i++
                        }
                    })
                }
                else {
                    audioChapter.downloadTask = DS.session.downloadTaskWithResumeData(audioChapter.taskResumeData!)
                    // Indicate for each file that is being downloaded.
                    audioChapter.isDownloading = true
                    audioChapter.downloadPaused = false
                    NSNotificationCenter.defaultCenter().postNotificationName(kDownloadStartedNotification, object: nil,  userInfo:["audiChapter": audioChapter])
                    i++
                }
            }
            
            // Break on 6 items otherwise the UI will freeze
            if i == 5 {
                break
            }
        }
        
        if i > 0 {
            // Disable the download all button
            downloadAllButton.enabled = false
            
            // Reload the table view.
            tableView.reloadData()
        }
    }
    
    @IBAction func startAllDownloads(sender: AnyObject) {
        confirmDownload(startFirstOfAllDownloadsNow)
        Flurry.logEvent(FlurryEvent.downloadAll, withParameters: ["reciter" : reciter.name])
    }
    
    func confirmDownload(callBack: () -> ()) {
        let alert = UIAlertController(title: "Info".local, message: nil, preferredStyle: .ActionSheet)
        if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WiFi || ($.allowDownloadOn3G && IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WWAN ){
            callBack()
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WWAN {
            alert.message = "Downloading via 3G/4G connection?".local
            let agreeDownloadOn3G =  UIAlertAction(title: "Continue".local, style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                callBack()
                $.allowDownloadOn3G = true
                Flurry.logEvent(FlurryEvent.downloadFrom3G)
            })
            alert.addAction(agreeDownloadOn3G)
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.NotConnected {
            alert.message = "You are not connected to the internet.".local
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            Flurry.logEvent(FlurryEvent.downloadNoConnection)
        }
    }
    
    // MARK: Notifications
    
    func progressUpdatedHandler(notification: NSNotification){
        //Action take on Notification
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if let cell: DownloadCell = tableView.cellForRowAtIndexPath( NSIndexPath(forRow: audioChapter.id, inSection: 0)) as? DownloadCell {
                //cell.progressView.stopSpinProgressBackgroundLayer()
                cell.progressView.progress = CGFloat(audioChapter.downloadProgress)
                cell.downloadPercentage.text = "\(Int(audioChapter.downloadProgress  * 100))%"
            }
        }
    }
    
    func downloadStartedHandler(notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            let index: NSIndexPath = NSIndexPath(forRow: notifChapter.id, inSection: 0)
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    func downloadCompleteHandler(notification: NSNotification){
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: audioChapter.id, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            if let nextToDownload = getNextAudioChapterToDownload() {
                if multipleDownload == true {
                    if firstNotDownloadedAudioChapter != nil {
                        startAllDownloadsNow()
                        firstNotDownloadedAudioChapter = nil
                    }
                    else{
                        let index: NSIndexPath = NSIndexPath(forRow: nextToDownload.id, inSection: 0)
                        self.startDownload(nextToDownload, handler: { (Void) -> Void in
                            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
                        })
                        tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)
                    }
                }
            }
            else {
                multipleDownload = false
            }
            downloadAllButton.enabled = !isDownloading() && isPro
        }
    }
    
    func downloadDeadHandler(notification: NSNotification){
        if notification.userInfo!["audiChapter"] as? AudioChapter != nil {
            let showError: Bool = (multipleDownload == true && !errorWasShown) || !multipleDownload
            if showError {
                // Access all AudioChapter objects using a loop.
                for audioChapter in self.reciter.audioChapters {
                    // Check if a file is already being downloaded or not.
                    if !audioChapter.isDownloaded && audioChapter.isDownloading {
                        audioChapter.reset()
                        audioChapter.downloadTask?.cancel()
                        NSNotificationCenter.defaultCenter().postNotificationName(kDownloadCancelAllNotification, object: nil,  userInfo:["audiChapter": audioChapter])
                    }
                }
                
                self.downloadAllButton.enabled = isPro
                self.cancelAll = true
                self.tableView.reloadData()
                showDownloadError()
            }
        }
    }
    
    func downloadErrorHandler(notification: NSNotification){
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if $.currentReciter.mirrorIndex == MirrorIndex.ERROR {
                //puff we have an issue here
            }
            else if $.currentReciter.mirrorIndex != MirrorIndex.IH2 {
                $.currentReciter.mirrorIndex = MirrorIndex(rawValue: $.currentReciter.mirrorIndex.rawValue + 1)!
                //try again
                startDownload(audioChapter, handler: { (Void) -> Void in
                    audioChapter.isRetrying = true
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: audioChapter.id, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                })
                
            }
            //last mirror not found so show the error
            else{
                $.currentReciter.mirrorIndex = MirrorIndex.ERROR
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: audioChapter.id, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                showDownloadError()
            }
        }
    }
    
    // MARK: Actionsheet
    
    func createActionSheet(audioChapter: AudioChapter, cell: DownloadCell) {
        
        let sportAllDownloadsAction =  UIAlertAction(title: "Stop All Downloads".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            var hasAtLeastOneDownload = false
            // Access all AudioChapter objects using a loop.
            for audioChapter in self.reciter.audioChapters {
                // Check if a file is already being downloaded or not.
                if !audioChapter.isDownloaded && audioChapter.isDownloading {
                    audioChapter.reset()
                    audioChapter.downloadTask?.cancel()
                    hasAtLeastOneDownload = true
                    NSNotificationCenter.defaultCenter().postNotificationName(kDownloadCancelAllNotification, object: nil,  userInfo:["audiChapter": audioChapter])
                }
            }
            
            if hasAtLeastOneDownload {
                self.multipleDownload = false
                self.downloadAllButton.enabled = isPro
                self.cancelAll = true
                self.tableView.reloadData()
            }
            
            Flurry.logEvent(FlurryEvent.stopAllDownloads)
        })
        
        let stopDownloadAction =  UIAlertAction(title: "Stop Download".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            // Change the isDownloading property value.
            audioChapter.reset()
            audioChapter.downloadTask?.cancel()
            
            // Reload the table view.
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: audioChapter.id, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            self.downloadAllButton.enabled = !self.isDownloading() && isPro
            
            NSNotificationCenter.defaultCenter().postNotificationName(kDownloadCancelAllNotification, object: nil,  userInfo:nil)
            Flurry.logEvent(FlurryEvent.stopDownload)
        })
        
        let deleteAudioAction = UIAlertAction(title: "Delete Download".local, style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(audioChapter.downloadFolder)
                } catch _ {
                }
            audioChapter.reset()
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: audioChapter.id, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            NSNotificationCenter.defaultCenter().postNotificationName(kAudioRemovedNotification, object: nil,  userInfo:["audiChapter": audioChapter])
            Flurry.logEvent(FlurryEvent.removeDownload, withParameters: ["fileName" : audioChapter.fileName, "reciter" : self.reciter.name])
        })
        
        let deleteAllAudiosAction = UIAlertAction(title: "Delete All Downloads".local, style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(audioChapter.reciterFolder)
                } catch _ {
                }
            self.resetAll()
            // Reload the table view.
            self.tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kAllAudiosRemovedNotification, object: nil,  userInfo:nil)
            Flurry.logEvent(FlurryEvent.removeAllDownloads, withParameters: ["reciter" : self.reciter.name])
        })
        
        //
        let dismissAction = UIAlertAction(title: "Cancel".local, style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        DS.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                let alert = UIAlertController(title: self.reciter.name, message: nil, preferredStyle: .ActionSheet)
                //execute in the main thread
                if downloadTasks.count == 0 {
                    alert.addAction(deleteAudioAction)
                    alert.addAction(deleteAllAudiosAction)
                }
                else if downloadTasks.count == 1 {
                    alert.addAction(stopDownloadAction)
                }
                else if downloadTasks.count > 1 {
                    alert.addAction(sportAllDownloadsAction)
                }
                //We need to provide a popover sourceView when using it on iPad
                if isIpad {
                    let popPresenter: UIPopoverPresentationController = alert.popoverPresentationController!
                    popPresenter.sourceView = cell;
                    popPresenter.sourceRect = cell.bounds
                }
                
                alert.addAction(dismissAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Units
    
    // Check if the download is beging performed
    func isDownloading() -> Bool {
        // Access all AudioChapter objects using a loop.
        for audioChapter in reciter.audioChapters {
            if audioChapter.isDownloading {
                return true
            }
        }
        return false
    }

    // Gets the next possible audio item to download
    func getNextAudioChapterToDownload () -> AudioChapter? {
        if (cancelAll == true) {
            return nil
        }
        // Access all AudioChapter objects using a loop.
        var audioChapter: AudioChapter!
        for i in 0...(reciter.audioChapters.count - 1) {
            audioChapter = reciter.audioChapters[i]
            if !audioChapter.isDownloaded && !audioChapter.isDownloading {
                return audioChapter
            }
        }
        
        return nil
    }
    
    func resetAll () {
        for audioChapter in reciter.audioChapters {
            audioChapter.reset()
        }
    }
}
