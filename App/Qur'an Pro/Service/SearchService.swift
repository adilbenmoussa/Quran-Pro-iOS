//
//  SearchService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//


class SearchService {
    
    class var instance: SearchService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SearchService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SearchService()
        }
        return Static.instance!
    }
    
    
    //hierarchical chapters and versers
    //Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func initialKeysAndContents() -> (keys: NSMutableArray, contents: NSMutableDictionary){
        let contents:NSMutableDictionary = [:]
        let keys:NSMutableArray = []
        var key: String
        
        //Construct the key list with empty content
        for chapter in $.chapters {
            key = $.getKeyId(chapter)
            if (contents.objectForKey(key) == nil) {
                keys.addObject(key)
                let list = NSMutableArray()
                for verse in chapter.verses {
                    if verse.id != -1 {
                        list.addObject(verse)
                    }
                }
                contents.setObject(list, forKey: key)
            }
        }
        return (keys: keys, contents: contents)
    }
    
    //Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func sortedKeysAndContents(list: NSMutableArray) -> (keys: NSMutableArray, contents: NSMutableDictionary){
        let sortedByChapter: NSArray = list.sortedArrayUsingDescriptors([NSSortDescriptor(key: "chapterId", ascending: true)])
        let sortedByVerse: NSArray = list.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)])
        
        let contents:NSMutableDictionary = [:]
        let keys:NSMutableArray = []
        
        var chapter: Chapter
        var verse: Verse
        var values: NSMutableArray
        var key: String
        
        //Construct the key list with empty content
        for item in sortedByChapter {
            if let v: Verse = item as? Verse {
                chapter = $.chapters[v.chapterId]
                key = $.getKeyId(chapter)
                if (contents.objectForKey(key) == nil) {
                    keys.addObject(key)
                    contents.setObject(NSMutableArray(), forKey: key)
                }
            }
        }
        
        //fill in the content of the keys
        for item in sortedByVerse {
            if let v: Verse = item as? Verse {
                chapter = $.chapters[v.chapterId]
                key = $.getKeyId(chapter)
                if (contents.objectForKey(key) != nil) {
                    values = (contents.objectForKey(key) as? NSMutableArray)!
                    if v.chapterId == chapter.id {
                        var verseId: Int = v.id
                        if chapter.id == kFatihaIndex || chapter.id == kTaubahIndex {
                            verseId = verseId - 1
                        }
                        verse = chapter.verses[verseId]
                        values.addObject(verse)
                    }
                    contents.setObject(values, forKey: key)
                }
            }
        }
        return (keys: keys, contents: contents)
    }

}