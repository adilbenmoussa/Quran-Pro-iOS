//
//  BookmarkService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

class BookmarkService {
    // Singlton instance
    class var instance: BookmarkService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: BookmarkService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = BookmarkService()
            Static.instance!.load()
        }
        return Static.instance!
    }
    
    //keep a reference to the bookmarks
    var bookMarks: NSMutableArray!;
    
    //Load the persitent bookmarks
    private func load(){
        // Loads the bookmarks
        if let bookMarksData = NSBundle.readArrayPlistFromDocumentFolder(kBookmarkFile) {
            bookMarks = bookMarksData.mutableCopy() as! NSMutableArray
        }
        // No bookmarkt found yet, so create a new empty file
        else{
            bookMarks = NSMutableArray()
            NSBundle.writeArrayPlistToDocumentFolder(filename: kBookmarkFile, array: self.bookMarks)
        }
    }
    
    //Check the passed wheter the passed verse is bookmarked or not
    func has(verse: Verse) -> Bool {
        for bookmark in bookMarks {
            if let kBookmark  = bookmark as? NSDictionary {
                if (kBookmark.objectForKey(kChapterhId) as? Int == verse.chapterId) && (kBookmark.objectForKey(kVerseId) as? Int == verse.id) {
                    return true
                }
            }
        }
        return false
    }
    
    //Remove the passed verse from the bookmark
    func remove(verse: Verse){
        var dirty = false
        for bookmark in bookMarks {
            if let kBookmark  = bookmark as? NSDictionary {
                if (kBookmark.objectForKey(kChapterhId) as? Int == verse.chapterId) && (kBookmark.objectForKey(kVerseId) as? Int == verse.id) {
                    bookMarks.removeObject(bookmark)
                    dirty = true
                    break
                }
            }
        }
        
        if dirty {
            NSBundle.writeArrayPlistToDocumentFolder(filename: kBookmarkFile, array: bookMarks)
        }
    }
    
    //Add the passed verse from the bookmark
    func add(verse: Verse){
        bookMarks.addObject([kChapterhId: verse.chapterId, kVerseId: verse.id])
        NSBundle.writeArrayPlistToDocumentFolder(filename: kBookmarkFile, array: bookMarks)
    }
    
    //Remove all bookmarks
    func clear() {
        bookMarks = NSMutableArray()
        NSBundle.writeArrayPlistToDocumentFolder(filename: kBookmarkFile, array: bookMarks)
    }
    
    //Check if the bookmark list is empty
    func isEmpty () -> Bool{
        return bookMarks.count == 0
    }
    
    
    //Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func sortedKeysAndContents() -> (keys: NSMutableArray, contents: NSMutableDictionary){
        let sortedBookmarksByChapter: NSArray = bookMarks.sortedArrayUsingDescriptors([NSSortDescriptor(key: kChapterhId, ascending: true)])
        let sortedBookmarksByVerse: NSArray = bookMarks.sortedArrayUsingDescriptors([NSSortDescriptor(key: kVerseId, ascending: true)])
        
        let contents:NSMutableDictionary = [:]
        let keys:NSMutableArray = []
        
        var chapter: Chapter
        var verse: Verse
        var values: NSMutableArray
        var key: String
        
        //Construct the key list with empty content
        for item in sortedBookmarksByChapter {
            chapter = $.chapters[item.objectForKey(kChapterhId) as! Int]
            key = $.getKeyId(chapter)
            if (contents.objectForKey(key) == nil) {
                keys.addObject(key)
                contents.setObject(NSMutableArray(), forKey: key)
            }
        }
        
        //fill in the content of the keys
        for item in sortedBookmarksByVerse {
            chapter = $.chapters[item.objectForKey(kChapterhId) as! Int]
            key = $.getKeyId(chapter)
            if (contents.objectForKey(key) != nil) {
                values = (contents.objectForKey(key) as? NSMutableArray)!
                if item.objectForKey(kChapterhId) as? Int == chapter.id {
                    var verseId: Int = (item.objectForKey(kVerseId) as? Int)!
                    if chapter.id == kFatihaIndex || chapter.id == kTaubahIndex {
                        verseId = verseId - 1
                    }
                    verse = chapter.verses[verseId]
                    values.addObject(verse)
                }
                contents.setObject(values, forKey: key)
            }
        }
        return (keys: keys, contents: contents)
    }
}
