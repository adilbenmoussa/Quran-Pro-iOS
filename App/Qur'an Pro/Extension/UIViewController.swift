//
//  UIViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension UIViewController {
    
    
    func askUserForPurchasingProVersion(logsKey: String) {
        //NSNotificationCenter.defaultCenter().postNotificationName(kOpenSKControllerNotification, object: nil,  userInfo: nil)
        FlurryEvent.logPurchase(logsKey)
        UIApplication.sharedApplication().openURL(NSURL(string: kAppUrl.localizeWithFormat(kQuranProId))!)
    }
    
    public func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = kSectionBackgrondFont
            header.textLabel?.textColor = UIColor.whiteColor()
            header.tintColor = kSectionBackgrondColor
        }
    }
    
    func overrideBackButton(){
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        navigationItem.leftBarButtonItem = backButton
    }
    
    func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    func startDownload (audioChapter: AudioChapter, handler: (() -> ())?) {
        let alert = UIAlertController(title: "Info".local, message: nil, preferredStyle: .ActionSheet)
        if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WiFi || ($.allowDownloadOn3G && IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WWAN ){
            startDownloadNow(audioChapter)
            handler?()
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.WWAN {
            alert.message = "Downloading via 3G/4G connection?".local
            let agreeDownloadOn3G =  UIAlertAction(title: "Continue".local, style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.startDownloadNow(audioChapter)
                // Reload the table view.
                handler?()
                //tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                $.allowDownloadOn3G = true
            })
            alert.addAction(agreeDownloadOn3G)
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.NotConnected {
            alert.message = "You are not connected to the internet.".local
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func startDownloadNow (audioChapter: AudioChapter) {
        if audioChapter.taskIdentifier == -1 || audioChapter.taskResumeData == nil {
            // Create a new task, but check whether it should be created using a URL or resume data.
            
            urlRequest(audioChapter, resultHandler: { request in
                if request != nil {
                    audioChapter.downloadTask = DS.session.downloadTaskWithRequest(request!)
                    audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier
                    
                    // Start the task.
                    audioChapter.downloadTask?.resume()
                }
                else{
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        //handle the error here....
                        NSNotificationCenter.defaultCenter().postNotificationName(kDownloadDeadNotification, object: nil,  userInfo:["audiChapter": audioChapter])
                        Flurry.logEvent(FlurryEvent.downloadDead)
                    })
                }
            })
        }
        else {
            // Create a new download task, which will use the stored resume data.
            audioChapter.downloadTask = DS.session.downloadTaskWithResumeData(audioChapter.taskResumeData!)
            audioChapter.downloadTask?.resume()
            // Keep the new download task identifier.
            audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier;
        }
        
        // Change the isDownloading property value.
        audioChapter.isDownloading = !audioChapter.isDownloading;
        NSNotificationCenter.defaultCenter().postNotificationName(kDownloadStartedNotification, object: nil,  userInfo:["audiChapter": audioChapter])
    }

    // Gets the url request based on the current mirror
    func urlRequest(audioChapter:AudioChapter, resultHandler:(NSURLRequest?)->()) {
        var kMirror:String?
        //we have an error state here
        if $.currentReciter.mirrorIndex == MirrorIndex.ERROR {
            resultHandler(nil)
        }
        if $.currentReciter.mirrorIndex == MirrorIndex.IH1 || $.currentReciter.mirrorIndex == MirrorIndex.IH2 {
            if $.currentReciter.mirrorIndex == MirrorIndex.IH1 && $.currentReciter.mirrors[MirrorIndex.IH1.rawValue] != nil {
                kMirror = $.currentReciter.mirrors[MirrorIndex.IH1.rawValue]! + audioChapter.fileName
            }
            else if $.currentReciter.mirrorIndex == MirrorIndex.IH2 && $.currentReciter.mirrors[MirrorIndex.IH2.rawValue] != nil {
                kMirror = $.currentReciter.mirrors[MirrorIndex.IH2.rawValue]! + audioChapter.fileName
            }
            else{
                //download the new mirror list from bitbucket repo
                PlistDownloader.load(kDownloadMirrorUrl, finished: { result in
                    if let list: Array<NSDictionary> = result as? Array<NSDictionary> {
                        if let dic: NSDictionary = list[$.currentReciter.id] {
                            if let m1: String = dic.objectForKey("m1") as? String {
                                $.currentReciter.mirrors[MirrorIndex.IH1.rawValue] = m1
                                kMirror = $.currentReciter.mirrors[MirrorIndex.IH1.rawValue]! + audioChapter.fileName
                            }
                            if let m2: String = dic.objectForKey("m2") as? String {
                                $.currentReciter.mirrors[MirrorIndex.IH2.rawValue] = m2
                                if kMirror == nil {
                                    kMirror = $.currentReciter.mirrors[MirrorIndex.IH2.rawValue]! + audioChapter.fileName
                                }
                            }

                            if kMirror != nil {
                                resultHandler(NSURLRequest(URL: NSURL(string: kMirror!)!))
                            }
                        }
                    }
                    }, fault: {error in
                        resultHandler(nil)
                })
            }
        }
        else if $.currentReciter.mirrorIndex == MirrorIndex.ABM {
            kMirror = $.currentReciter.mirrors[MirrorIndex.ABM.rawValue]! + audioChapter.fileName
        }
        else if $.currentReciter.mirrorIndex == MirrorIndex.PMA {
            kMirror = $.currentReciter.mirrors[MirrorIndex.PMA.rawValue]! + audioChapter.fileName
        }

        if kMirror != nil {
            resultHandler(NSURLRequest(URL: NSURL(string: kMirror!)!))
        }
        else{
            resultHandler(nil)
        }
    }
    
    func showDownloadError() {
        let alertController = UIAlertController(title: "Info".local, message:
            "Something went wrong during downloading, please try later on again.".local, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        let moreInfo = "[currentKey: \($.currentLanguageKey), NSUserDefaultsLanguageKey: \(NSUserDefaults.currentLanguageKey())]"
        Flurry.logError(FlurryEvent.downloadError, message: "Something went wrong during downloading, please try later on again. \(moreInfo)", error: nil)
    }

}