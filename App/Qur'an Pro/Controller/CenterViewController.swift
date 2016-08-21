//
//  CenterViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
import Social
import AVFoundation

@objc
protocol CenterViewControllerDelegate {
    optional func toggleChaptersPanel()
    optional func toggleMorePanel()
    optional func collapseSidePanels()
}

class CenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, AudioDelegate {
    
    let service: AudioService = AudioService.instance
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    var activityIndicatorView: UIActivityIndicatorView!
    var originalTitleView: UIView!
    var originalLeftBarButtonItems:[AnyObject]?
    var currentArabicFont: UIFont!
    var currentLatinFont: UIFont!
    
    var isScrolling: Bool = false
    var currentVerseIndex: Int = 0
    var currentAudioChapter:AudioChapter!
    var delegate:CenterViewControllerDelegate?
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        service.initDelegation(self)
        navigationController?.hidesBarsOnSwipe = true
        originalTitleView = self.navigationItem.titleView
        originalLeftBarButtonItems = self.navigationItem.leftBarButtonItems
        currentAudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicatorView.startAnimating()
        progress.setProgress(0, animated: false)
        view.sendSubviewToBack(tableView)
        updateControls()
        tableViewReloadData()
        registerNotification()
        updateFont()
    }
    
    //update to the font to use
    func updateFont() {
        currentArabicFont = UIFont.arabicFont()
        currentLatinFont = UIFont.latin()
    }
    func registerNotification() {
        let notifier: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notifier.addObserver(self, selector: "newChapterSelectedHandler:", name:kNewChapterSelectedNotification, object: nil)
        notifier.addObserver(self, selector: "newVerseSelectedHandler:", name:kNewVerseSelectedNotification, object: nil)
        notifier.addObserver(self, selector: "progressUpdatedHandler:", name:kProgressUpdatedNotification, object: nil)
        notifier.addObserver(self, selector: "downloadStartedHandler:", name:kDownloadStartedNotification, object: nil)
        notifier.addObserver(self, selector: "downloadCompleteHandler:", name:kDownloadCompleteNotification, object: nil)
        notifier.addObserver(self, selector: "downloadDeadHandler:", name:kDownloadDeadNotification, object: nil)
        notifier.addObserver(self, selector: "downloadErrorHandler:", name:kDownloadErrorNotification, object: nil)
        notifier.addObserver(self, selector: "downloadCancelHandler:", name:kDownloadCancelNotification, object: nil)
        notifier.addObserver(self, selector: "downloadCancelAllHandler:", name:kDownloadCancelAllNotification, object: nil)
        notifier.addObserver(self, selector: "audioRemovedHandler:", name:kAudioRemovedNotification, object: nil)
        notifier.addObserver(self, selector: "allAudiosRemovedHandler:", name:kAllAudiosRemovedNotification, object: nil)
        notifier.addObserver(self, selector: "reciterChangedHandler:", name:kReciterChangedNotification, object: nil)
        notifier.addObserver(self, selector: "translationChangedHandler:", name:kTranslationChangedNotification, object: nil)
        notifier.addObserver(self, selector: "viewChangedHandler:", name:kViewChangedNotification, object: nil)
        notifier.addObserver(self, selector: "bookmarksRemovedHandler:", name:kBookmarksRemovedNotification, object: nil)
        notifier.addObserver(self, selector: "beginReceivingRemoteControlEventsHandler:", name:kBeginReceivingRemoteControlEvents, object: nil)
    }
    
    func updatePlayControls(){
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.text = "\($.currentChapter.name) - \($.currentReciter.name)"
        let closePlayControlerBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: Selector("closePlayControlClickedHandler"))
        
        let repeatBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: service.repeatIconName()), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("repeatClickedHandler"))
        repeatBtn.enabled = isPro
        
        let resumeBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "play"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("resumeClickedHandler"))
        resumeBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsAudioRight/2);
        
        let pauseBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pause"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("pauseClickedHandler"))
        pauseBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsAudioRight/2);
        
        let nextBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "next"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("nextClickedHandler"))
        
        let previousBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "previous"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("previousClickedHandler"))
        previousBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsAudioRight);
        
        var playControlItems: Array<UIBarButtonItem> = []
        playControlItems = [closePlayControlerBtn, nextBtn, previousBtn]
        if service.isPlaying() {
            playControlItems.insert(pauseBtn, atIndex: playControlItems.count - 1)
        }
        else{
            playControlItems.insert(resumeBtn, atIndex: playControlItems.count - 1)
        }
        
        //self.navigationItem.rightBarButtonItems = [closePlayControlerBtn, nextBtn, pauseBtn, previousBtn]
        self.navigationItem.rightBarButtonItems = playControlItems
        self.navigationItem.leftBarButtonItems = [repeatBtn]
        navigationItem.titleView = UIView(frame: CGRect())
    }
    
    // Update the controls depending on the state of the audio file
    func updateControls() {
        
        // when plying
        if (service.isPlaying() || service.isPaused == true ) {
            updatePlayControls()
            return
        }
        
        //chapters.png
        let downloadImageName = "download_cloud" + (!isPro && currentAudioChapter.id != 0 && currentAudioChapter.id != 1  ? "-disabled" : "")
        let downloadBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: downloadImageName), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("downloadClickedHandler"))
        downloadBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsRight);
        let showAudioControlBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "show-audio-controls"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("showAudioControlsHandler"))
        
        showAudioControlBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsRight);
        
        let activityIndicatorBtn: UIBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 20);

        let moreBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleMorePanel:"))
        
        var buttons:Array<UIBarButtonItem> = [moreBtn]
        if currentAudioChapter.isDownloaded {
            buttons.append(showAudioControlBtn)
        }
        else if currentAudioChapter.isDownloading {
            buttons.append(activityIndicatorBtn)
        }
        else{
            buttons.append(downloadBtn)
        }
        self.navigationItem.rightBarButtonItems = buttons
        self.navigationItem.leftBarButtonItems = originalLeftBarButtonItems as? [UIBarButtonItem]
        self.navigationItem.titleView = originalTitleView
        progress.hidden = false
        //update the progress comtrol
        if currentAudioChapter != nil && currentAudioChapter.isDownloading {
            view.bringSubviewToFront(progress)
            progress.trackTintColor = UIColor.whiteColor()
            progress.setProgress(currentAudioChapter.downloadProgress, animated: false)
        }
        else{
            view.sendSubviewToBack(progress)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets the title
        self.title = "\($.currentChapter.id + 1). \($.currentChapter.name.local)"
        self.tableView.estimatedRowHeight = 120.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Actions
    
    @IBAction func toggleChapterPanel(sender: AnyObject) {
        Flurry.logEvent(FlurryEvent.toggleChapterPanel)
        delegate?.toggleChaptersPanel!()
    }
    
    @IBAction func toggleMorePanel(sender: AnyObject) {
        Flurry.logEvent(FlurryEvent.toggleMorePanel)
        delegate?.toggleMorePanel!()
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return $.currentChapter.verses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "VerseCellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VerseCell
        
        let verse = $.currentChapter.verses[indexPath.row]
        //set up the font
        cell.arabic.font = currentArabicFont
        cell.translation.font = currentLatinFont
        cell.transcription.font = currentLatinFont
        
        //set up the content
        contentForCell(verse, cell:cell)
        
        //set up the bookmark icons
        cell.bookmarkView.hidden = !BookmarkService.instance.has(verse)
        
        //hold a reference of the verse id into the cell
        cell.verseId = verse.id
        
        // set the background for the verse view depending on the odd/event index and the hizb option
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = verse.hizbId != -1 ? kHizbTableCellColor : ((indexPath.row % 2) == 0) ? kVerseCellyOddColor : kVerseCellyEvenColor
        cell.backgroundView = view
        
        // needed to fix an issue with UITableViewAutomaticDimension not working until scroll
        //http://useyourloaf.com/blog/2014/08/07/self-sizing-table-view-cells.html
        //cell.setNeedsDisplay()
        cell.layoutIfNeeded()
        
        //return the cell
        return cell
    }
    
    // get the content representation depending on the settings
    private func contentForCell (verse: Verse, cell: VerseCell) {
        //"﴾﴿"
        let numbers = "\(verse.chapterId + 1):\(verse.id)"
        cell.arabic.text = !$.showTranslation ? verse.translation != "" ? "\(numbers)  \(verse.arabic)" : verse.arabic : verse.arabic
        cell.transcription.text = $.showTransliteration ?  verse.transcription : ""
        cell.translation.text = $.showTranslation ? verse.translation != "" ? "\(numbers) \(verse.translation)" : "" : ""

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: VerseCell  = tableView.cellForRowAtIndexPath(indexPath) as! VerseCell
        cell.contentView.backgroundColor = kSelectedCellBackgroudColor
        let verse = $.currentChapter.verses[indexPath.row]
        
        if(verse.id != -1){
            showActionSheetAlert(verse, cell: cell)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    //TODO remove this if not needed anymore
    // needed to fix an issue with UITableViewAutomaticDimension not working until scroll
    func tableViewReloadData() {
        tableView.reloadData()
        //tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections())), withRowAnimation: .None)
    }
    
    // MARK: Notifications
    
    //handle the new chapter selection
    func newChapterSelectedHandler(notification: NSNotification){
        // sets the title
         if let userInfo = notification.userInfo {
            if let chapter: Chapter = userInfo["chapter"] as? Chapter {
                if chapter.id != currentAudioChapter.id {
                    if self.service.isPlaying() {
                        self.service.stopAndReset()
                    }
                    self.service.isPaused = false
                    self.title = "\($.currentChapter.id + 1). \($.currentChapter.name.local)"
                    currentAudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
                    self.updateControls()
                    tableViewReloadData()
                    self.scrollToVerse(0)
                }
            }
        }
        self.delegate?.toggleChaptersPanel!()
    }
    
    //handle the new verse selection
    func newVerseSelectedHandler(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let verse: Verse = userInfo["verse"] as? Verse {
                let chapter = $.chapters[verse.chapterId]
                if chapter.id != $.currentChapter.id {
                    if self.service.isPlaying() {
                        self.service.stopAndReset()
                    }
                    self.service.isPaused = false
                    $.setAndSaveCurrentChapter(chapter)
                    self.title = "\(chapter.id + 1). \(chapter.name.local)"
                    currentAudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
                    tableViewReloadData()
                    updateControls()
                }
                var verserId = verse.id
                //correct the position the of te verse to scroll to
                if (verse.chapterId == kTaubahIndex) || (verse.chapterId == kFatihaIndex) {
                    --verserId
                }
                self.scrollToVerse(verserId, searchText: userInfo["searchText"] as? String)
                if let toggle = userInfo["toggle"] as? String {
                    if toggle == "left"{
                        delegate?.toggleChaptersPanel!()
                    }
                    else{
                        delegate?.toggleMorePanel!()
                    }
                    
                }
            }
        }
    }
    
    func progressUpdatedHandler(notification: NSNotification){
        //Action take on Notification
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                progress.setProgress(notifChapter.downloadProgress, animated: true)
            }
        }
    }
    
    func downloadStartedHandler(notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    func downloadCompleteHandler(notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    func downloadCancelHandler (notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    func downloadCancelAllHandler (notification: NSNotification){
        self.updateControls()
    }
    
    func reciterChangedHandler (notification: NSNotification){
        currentAudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
        self.updateControls()
    }
    
    func downloadDeadHandler (notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if currentAudioChapter.id == notifChapter.id {
                currentAudioChapter.reset()
                self.updateControls()
                showDownloadError()
            }
        }
    }
    
    
    //todo, move this and the downloadview version to a global version
    func downloadErrorHandler(notification: NSNotification){
        self.updateControls()
//        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
//            if currentAudioChapter.id == notifChapter.id {
//                //self.updateControls()
//                if DS.currentMirrorIndex == MirrorIndex.ERROR {
//                    //puff we have an issue here
//                }
//                else if DS.currentMirrorIndex != MirrorIndex.IH2 {
//                    DS.currentMirrorIndex = MirrorIndex(rawValue: DS.currentMirrorIndex.rawValue + 1)!
//                    //try again
//                    startDownload(currentAudioChapter, handler: { (Void) -> Void in
//                        self.currentAudioChapter.isRetrying = true
//                        self.updateControls()
//                    })
//                    
//                }
//                //last mirror not found so show the error
//                else{
//                    DS.currentMirrorIndex = MirrorIndex.ERROR
//                    self.updateControls()
//                    showDownloadError()
//                }
//                
//            }
//        }
    }
    
    
    //handles the remote control costum events from the delegate
    func beginReceivingRemoteControlEventsHandler(notification: NSNotification){
        if let event: UIEvent = notification.object as? UIEvent {
            switch event.subtype {
            case .RemoteControlTogglePlayPause:
                service.isPlaying() ? pauseClickedHandler() : resumeClickedHandler()
            case .RemoteControlPlay:
                resumeClickedHandler()
            case .RemoteControlPause:
                pauseClickedHandler()
            case .RemoteControlNextTrack:
                nextClickedHandler()
            case .RemoteControlPreviousTrack:
                previousClickedHandler()
            default:break
            }
        }
    }
    
    //update the ui contols
    func audioRemovedHandler(notification: NSNotification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                updateControls()
            }
        }
    }
    
    //update the ui contols
    func allAudiosRemovedHandler(notification: NSNotification){
        updateControls()
    }

    //update the ui contols
    func translationChangedHandler(notification: NSNotification){
        tableViewReloadData()
    }
    
    //update the ui contols
    func viewChangedHandler(notification: NSNotification){
        updateFont()
        tableViewReloadData()
    }

    //update the bookmarks
    func bookmarksRemovedHandler(notification: NSNotification){
        tableViewReloadData()
    }

    // MARK - Scrolling delegate handlers

    //Saves the scrolling state
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        self.isScrolling = true
    }
    
    //Saves the middle verse id when scrolling was stopped.
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        self.isScrolling = false
        let visibleCells = tableView.visibleCells
        let middleItemIndex = visibleCells.count / 2
        if let verseCell: VerseCell = visibleCells[middleItemIndex] as? VerseCell {
            self.currentVerseIndex = verseCell.verseId
        }
    }
    
    // Scroll the provided verseId
    // @param verseId   the verse index to scroll to
    func scrollToVerse(verseId: Int, searchText:String? = nil){
        if verseId < $.currentChapter.verses.count {
            let verse = $.currentChapter.verses[verseId]
            if let row: Int = $.currentChapter.verses.indexOf(verse) {
                let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: 0)
                //tableView.scrollToNearestSelectedRowAtScrollPosition(UITableViewScrollPosition.Bottom, animated: true)
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                if searchText != "" && searchText != nil {
                    if let cell: VerseCell  = tableView.cellForRowAtIndexPath(indexPath) as? VerseCell{
                        var label: UILabel!
                        //skip highlighting arabic texts
                        if $.searchOption != SearchOption.SearchOptionArabic {
                            if $.searchOption == SearchOption.SearchOptionTrasliteration {
                                label = cell.transcription
                            }
                            else if $.searchOption == SearchOption.SearchOptionTraslation {
                                label = cell.translation
                            }
                            highlightText(searchText!, inLabel: label)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: AudioDelegate
    func playNextChapter(){
        if $.currentChapter.id < $.chapters.count - 1 {
            let nextChapter: Chapter = $.chapters[$.currentChapter.id  + 1]
            let audioChapter = $.currentReciter.audioChapters[nextChapter.id]
            $.setAndSaveCurrentChapter(nextChapter)
            self.title = "\(nextChapter.id + 1). \(nextChapter.name.local)"
            currentAudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
            self.currentVerseIndex = 0
            tableViewReloadData()
            scrollToVerse(currentVerseIndex, searchText: "")
            //audio of the next chapter is found, so play it
            if audioChapter.isDownloaded {
                service.play(nextChapter.verses[0])
            }
            // no audio found for the next chapter, so, notify the use
            else{
                updateControls()
                self.view.makeToast(message: "Audio not downloaded yet.".local, duration: 2, position: HRToastPositionTop)
            }
        }
        else{
            updateControls()
        }
    }
    
    // MARK: Orientation delegate handlers
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
            coordinator.animateAlongsideTransition(nil, completion: {context in
                if !self.isScrolling && self.currentVerseIndex > 0 {
                   self.scrollToVerse(self.currentVerseIndex)
                }
        })
    }
    
    // MARK: Action sheet
    
    // Show action sheet alert
    func showActionSheetAlert(verse: Verse,  cell: VerseCell){
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
         //Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".local, style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //Just dismiss the action sheet
        })
        
        //Create play audio action
        let playAudioAction = UIAlertAction(title: "Play verse".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.service.play(verse)
            self.updateControls()
            Flurry.logEvent(FlurryEvent.playerAudioFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })
        
        //Create stop play audio action
        let stopAudioAction = UIAlertAction(title: "Stop playing".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.service.stopAndReset()
            self.updateControls()
            Flurry.logEvent(FlurryEvent.stopPlayingAudioFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })
        
        //Create download audio action
        let downloadAudioAction = UIAlertAction(title: "Download chapter".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.downloadClickedHandler()
            Flurry.logEvent(FlurryEvent.downloadFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })


        //Create and add the add-bookmark action
        let addBookmarkAction = UIAlertAction(title: "Add to bookmarks".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.instance.add(verse)
            //reload the cells in order to update the bookmark icon
            self.tableViewReloadData()
            Flurry.logEvent(FlurryEvent.addBookmark)
        })
        
        //Create and add the remove-bookmark action
        let removeBookmarkAction = UIAlertAction(title: "Remove from bookmarks".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.instance.remove(verse)
            //reload the cells in order to update the bookmark icon
            self.tableViewReloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kBookmarkChangedNotification, object: nil,  userInfo:nil)
            Flurry.logEvent(FlurryEvent.removeBookmark)
        })
        
        if !service.isPlaying() {
            if currentAudioChapter.isDownloaded {
                actionSheetController.addAction(playAudioAction)
            }
            else if !currentAudioChapter.isDownloading {
                actionSheetController.addAction(downloadAudioAction)
            }
        }
        else{
            actionSheetController.addAction(stopAudioAction)
        }
        
        if BookmarkService.instance.has(verse) {
            actionSheetController.addAction(removeBookmarkAction)
        }
        else{
            actionSheetController.addAction(addBookmarkAction)
        }
        
        //Social media
        let shareAction =  UIAlertAction(title: "Share".local + "...", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let activities = [(kApplicationDisplayName as String) + " - Surah " + $.currentChapter.name + " ayah " + String(verse.id), self.generateImage(cell), kShortenAppUrl]
                let ctr = UIActivityViewController(activityItems: activities, applicationActivities: nil)
            ctr.completionWithItemsHandler = { activity, success, items, error in
                if error != nil {
                    Flurry.logError(activity, message: "", error: error)
                }
                else{
                    Flurry.logEvent(activity, withParameters: ["success": success])
                }
            }
            ctr.excludedActivityTypes = [UIActivityTypePostToWeibo,
                //UIActivityTypeMessage,
                //UIActivityTypeMail,
                UIActivityTypePrint,
                UIActivityTypeCopyToPasteboard,
                UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAddToReadingList,
                //UIActivityTypePostToFlickr,
                UIActivityTypePostToVimeo,
                UIActivityTypePostToTencentWeibo,
                UIActivityTypeAirDrop]
            //We need to provide a popover sourceView when using it on iPad
            if isIpad {
                let popPresenter: UIPopoverPresentationController = ctr.popoverPresentationController!
                popPresenter.sourceView = cell;
                popPresenter.sourceRect = cell.bounds
            }
            
            //Present the AlertController
            self.presentViewController(ctr, animated: true, completion: nil)
        })
        
        //Create and add the add-bookmark action
        let copyAction = UIAlertAction(title: "Copy verse".local, style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            let text = "[Surah " + $.currentChapter.name + " ayah " + String(verse.id) + "]\n" + cell.translation.text! + "\n" + cell.arabic.text! + "\n" + cell.transcription.text! + "\n\n\n-----\n" + (kApplicationDisplayName as String)  + "\n" + kShortenAppUrl
            UIPasteboard.generalPasteboard().string = text
            Flurry.logEvent(FlurryEvent.copy)
        })

        actionSheetController.addAction(copyAction)
        actionSheetController.addAction(shareAction)
        actionSheetController.addAction(cancelAction)
        
        //We need to provide a popover sourceView when using it on iPad
        if isIpad {
            let popPresenter: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popPresenter.sourceView = cell;
            popPresenter.sourceRect = cell.bounds
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    func appUrl()-> String {
        let url = kAppUrlTemplate.localizeWithFormat($.currentLanguageKey, kAppId)
        return url
    }
    
    //generate the image
    func generateImage(cell: VerseCell) -> UIImage {
        let extraSpace:CGFloat = 20.0
        let text:NSString = (kApplicationDisplayName as String) + " - " + kShortenAppUrl
        //Create the UIImage
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(cell.frame.size.width, cell.frame.size.height + extraSpace), false, 0)
        cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //Save it to the camera roll
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0);
        image.drawInRect(CGRectMake(0, 0, image.size.width,image.size.height))
        let rect = CGRectMake(0, image.size.height - extraSpace , image.size.width, image.size.height)
        kImageWaterMarkColor.set()
        UIRectFill(rect)
        text.drawInRect(CGRectIntegral(rect), withAttributes: [NSFontAttributeName : kImageWaterMarkFont])
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    // MARK: hightlight
    
    //highlight the seach text in text view
    // see: http://www.raywenderlich.com/86205/nsregularexpression-swift-tutorial
    func highlightText(searchText: String, inLabel label: UILabel){
        //First, get a mutable copy of the label's attributedText.
        let attributedText = label.attributedText!.mutableCopy() as! NSMutableAttributedString
        //Then create an NSRange for the entire length of the text, and remove any background color text attributes that already exist within it.
        let attributedTextRange = NSMakeRange(0, attributedText.length)
        attributedText.removeAttribute(NSBackgroundColorAttributeName, range: attributedTextRange)
        //As with find and replace, next create a regular expression using your convenience initializer and fetch an array of all matches for the regular expression within the label’s text.
        do {
            let regex = try NSRegularExpression(pattern: searchText, options: NSRegularExpressionOptions.CaseInsensitive)
            let range = NSMakeRange(0, (label.text!).characters.count)
            let matches = regex.matchesInString(label.text!, options: [], range: range)
            //Loop through each match (casting them as NSTextCheckingResult objects), and add a yellow colour background attribute for each one.
            for match in matches as [NSTextCheckingResult] {
                let matchRange = match.range
                
                attributedText.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellowColor(), range: matchRange)
            }
        } catch _ {
        }
        //Finally, update the UITextView with the highlighted results.
        label.attributedText = attributedText.copy() as? NSAttributedString
    }
    
    // MARK: right bar item click handlers
    
    func downloadClickedHandler (){
        
        func handler () {
            self.startDownload(currentAudioChapter) { (Void) -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                self.updateControls()
            }
            Flurry.logEvent(FlurryEvent.downloadFromChapter)
        }
        if isPro {
            handler()
        }
        else{
            if currentAudioChapter.id == 0 || currentAudioChapter.id == 1 {
                handler()
            }
            else{
                self.askUserForPurchasingProVersion(FlurryEvent.downloadFromChapter)
            }
        }
    }
    
    func showAudioControlsHandler (){
        service.play()
        updateControls()
    }
    
    func resumeClickedHandler (){
        service.resumePlaying()
        updateControls()
    }
    
    func closePlayControlClickedHandler (){
        service.stopAndReset()
        updateControls()
    }
    
    func pauseClickedHandler (){
        service.pausePlaying()
        updateControls()
    }
    
    func previousClickedHandler() {
        service.playPrevious()
    }
    
    func nextClickedHandler() {
        service.playNext()
    }
    
    func repeatClickedHandler (){
        service.repeatPlay()
        updateControls()
    }
    
}
