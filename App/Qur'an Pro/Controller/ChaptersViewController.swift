//
//  ChaptersViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class ChaptersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "ChaptersCell")
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "PartsCell")
        tableView.estimatedRowHeight = 64.0;
        tableView.rowHeight = UITableViewAutomaticDimension;

        updateLabels()
    }

    // handles the left button click action
    func leftButtonClickHandler() {
        //toggle the view
        $.currentGroupViewType = hasChapterView() ? GroupViewType.GroupPartsView : GroupViewType.GroupChaptersView
        //Flurry.logEvent(FlurryEvent.sestionSelected, withParameters: ["index": $.currentGroupViewType.rawValue])// fout
        updateLabels()
        //reload the list
        tableView.reloadData()
        selectRowFromSetting()
        $.setPersistentObjectForKey($.currentGroupViewType.rawValue, key: kGrouViewTypeKey)
    }
    
    func updateLabels() {
        self.title = hasChapterView() ? "Chapters".local :  "Ajzā’"
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: $.currentGroupViewType == .GroupChaptersView ?  "parts" : "chapters"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("leftButtonClickHandler"))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func cellBackgroundColorAtIndexPath(indexPath: NSIndexPath) {
        let cell: UITableViewCell?  = tableView.cellForRowAtIndexPath(indexPath)
        cell?.contentView.backgroundColor = kSelectedCellBackgroudColor
    }
    
    func hasChapterView() -> Bool {
        return $.currentGroupViewType == .GroupChaptersView
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return hasChapterView() ? 1 : $.parts.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return hasChapterView() ? nil : "Juz'".local + "-" + "\(String($.parts[section].id))"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasChapterView() ? 114 : 8
    }

    // return list of section titles to display in section index view
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        if hasChapterView() {
//            return nil
//        }
//        else{
//            var indeces = [String]()
//            for i in 1...30 {
//                indeces.append(String(i))
//            }
//            return indeces;
//        }
//    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = hasChapterView() ? "Chapters" : "Parts"

        var cell = tableView.dequeueReusableCellWithIdentifier("\(cellId)Cell")
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "\(cellId)Cell")
        }
        if hasChapterView(){
            let chapter: Chapter = $.chapters[indexPath.row] as Chapter
            cell?.imageView!.image = UIImage(named: "sn\(chapter.id + 1)")
            cell?.textLabel!.text = "\(chapter.id + 1). \(chapter.name.local)"
            cell?.textLabel!.font = kCellTextLabelFont
            cell?.textLabel!.textColor = kCellTextLabelColor
            var verses = chapter.verses.count
            if (chapter.id != kTaubahIndex) && (chapter.id != kFatihaIndex) {
                --verses
            }
            cell?.detailTextLabel?.text = chapter.revelationLocation + " - \(verses) ayāt"
            cell?.detailTextLabel?.textColor = kCellTextLabelColor
        }
        else{
            let part: Part = $.parts[indexPath.section] as Part
            let partQuarter = part.partQuarters[indexPath.row]
            let chapter: Chapter = $.chapters[partQuarter.chapterId - 1] as Chapter
            var verseId = partQuarter.verseId
            if (partQuarter.chapterId - 1 == kFatihaIndex) || (partQuarter.chapterId - 1 == kTaubahIndex) {
                --verseId
            }
            let verse: Verse = chapter.verses[verseId]
            cell?.imageView!.image = nil
            let numbers = "\(verse.chapterId + 1):\(verse.id) "
            cell?.textLabel!.text = numbers + verse.translation
            cell?.textLabel!.font = kLatinSearchAndBookmarkFont
            cell?.detailTextLabel?.text = partQuarter.display()
            cell?.detailTextLabel?.textColor = kCellTextLabelColor
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kHeightForRowAtIndexPath
    }
    
    // Mark: Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if hasChapterView() {
            cellBackgroundColorAtIndexPath(indexPath)
            let chapter: Chapter = $.chapters[indexPath.row] as Chapter
            $.setAndSaveCurrentChapter(chapter)
            NSNotificationCenter.defaultCenter().postNotificationName(kNewChapterSelectedNotification, object: nil,  userInfo:["chapter": chapter])
            Flurry.logEvent(FlurryEvent.chapterSelected, withParameters: ["chapter": chapter.description])
        }
        else{
            let part: Part = $.parts[indexPath.section] as Part
            let partQuarter = part.partQuarters[indexPath.row]
            let chapter: Chapter = $.chapters[partQuarter.chapterId - 1] as Chapter
            var verseId = partQuarter.verseId
            if (partQuarter.chapterId - 1 == kFatihaIndex) || (partQuarter.chapterId - 1 == kTaubahIndex) {
                --verseId
            }
            let verse: Verse = chapter.verses[verseId]
            NSNotificationCenter.defaultCenter().postNotificationName(kNewVerseSelectedNotification, object: nil,  userInfo:["verse":verse, "verseReady":true, "toggle": "left"])
            Flurry.logEvent(FlurryEvent.verseViaSectionSelected, withParameters: ["verse": verse.description])
        }
        cellBackgroundColorAtIndexPath(indexPath)
    }
    
    // scroll the current chanpter and sets the bg color
    func selectRowFromSetting() {
        if hasChapterView() {
            if let row: Int = $.chapters.indexOf($.currentChapter) {
                let indexPath: NSIndexPath = NSIndexPath(forRow: row, inSection: 0)
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                cellBackgroundColorAtIndexPath(indexPath)
            }
        }
    }
}
