//
//  DataService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

enum PartQuarterType: Int {
    case One = 0, // 1
    OneFourth, // 1/4
    Half, // 1/2
    ThreeFourth // 3/4
}

enum RevelationLocationTpe: String {
    case Mecca = "Mecca",
    Medina = "Medina"
}

enum VerseViewType : Int {
    case NoTranslation = 0,
    NoTransliteration
}

enum ArabicFontType: Int {
    case UseMEQuranicFont = 0,
    UsePDMSQuranicFont,
    UseNormalArabicFont
}

enum FontSizeType : Int {
    case Medium = 0,
    Large,
    ExtraLarge
}

enum GroupViewType: Int {
    // 0- Suras
    // 1- Ajzaa'
    case GroupChaptersView = 0, GroupPartsView
}

enum SearchOption : Int {
    case SearchOptionTraslation = 0, SearchOptionArabic, SearchOptionTrasliteration
}

class DataService {
    
    // Singlton instance
    class var instance: DataService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DataService()
        }
        return Static.instance!
    }
    
    // list the all chapters
    var chapters: Array<Chapter>!
    // list of all verses
    var verses: Array<Verse>!
    // list of recites
    var reciters: Array<Reciter>!
    // list of the supported translations
    var translations: Array<Translation>!
    // current language
    var currentLanguageKey: String!
    // current reciter
    var currentReciter: Reciter!
    // current reciter
    var currentReciterIndex: Int!
    // current chapter
    var currentChapter: Chapter!
    // current chapter
    var currentChapterIndex: Int!
    // show allow download on 3G
    var allowDownloadOn3G: Bool
    // should show the translations
    var showTranslation: Bool
    // should show the transliteration
    var showTransliteration: Bool
    // font level
    var fontLevel: FontSizeType
    // should show the transliteration
    var searchOption: SearchOption
    //save the group view type
    var currentGroupViewType: GroupViewType!
    
    // current arabic font
    var arabicFont: ArabicFontType
    
    // parts (juz')
    var parts: [Part]
    
    init(){
        // inits the variables
        self.currentLanguageKey = kAppDefaultLanguage
        self.chapters = []
        self.verses = []
        self.reciters = []
        self.translations = []
        self.allowDownloadOn3G = false
        self.showTranslation = true
        self.showTransliteration = true
        self.fontLevel = FontSizeType.Medium
        self.searchOption = .SearchOptionTraslation
        self.arabicFont = .UseMEQuranicFont
        self.parts = []
        
        // sets the part(juz)
        self.initParts()
        
        // sets the current chapter
        self.initializeFromSetting()
        
        // load the languages
        self.loadTranslations()
        
        //init lang
        self.initLanguage()
        
        // init the chapters
        self.retrieveChapters()

        // init the content
        self.loadContent()
        
        // load the reciter data
        self.loadReciters()
        
        
        //init the current reciter and chapter
        self.currentChapter = chapters[self.currentChapterIndex]
        self.currentReciter = reciters[self.currentReciterIndex]
    }
    
    //check the availability of the passed lang
    func isLanguageAvailable(langKey: String) -> Bool{
        for translation in translations {
            if translation.id == langKey {
                return true
            }
        }
        return false
    }
    
    // init the current language
    func initLanguage() {
        if isPro {
            if (currentLanguageKey != nil && isLanguageAvailable(currentLanguageKey)) {
                //just use it
            }
            else if (isLanguageAvailable(NSUserDefaults.currentLanguageKey())) {
                currentLanguageKey = NSUserDefaults.currentLanguageKey()
            }
            else{
                currentLanguageKey = kAppDefaultLanguage
            }
        }
        else{
            currentLanguageKey = kAppDefaultLanguage
        }
    }
    
    // init the parts
    func initParts() {
        
        let items = NSMutableDictionary()
        var output = [NSMutableArray]()
        var juz = 1
        var count = 0
        for i in 0..<kPartQuarts.count {
            let array:NSMutableArray!
            if let a = items.objectForKey(juz) as? NSMutableArray {
                array = a
            }
            else{
                array = NSMutableArray()
                items.setObject(array, forKey: juz)
                output.append(array)
            }
            array.addObject(kPartQuarts[i])
            if i <= 7 {
                if count == 7 {
                    count = 0
                    juz++
                }
            }
            else{
                if count == 8 {
                    count = 0
                    juz++
                }
            }
            count++
        }
        
        var hizb = 0
        for i in 0..<output.count {
            let quarters = output[i]
            let partid = i+1
            let part = Part(id: partid)
            for j in 0..<quarters.count {
                if let quarter = quarters[j] as? [Int] {
                    if j == 0 || j == 4 {
                        hizb++
                    }
                    let type = j > 3 ? PartQuarterType(rawValue: j-4) : PartQuarterType(rawValue: j)
                    let partQuarter = PartQuarter(parentId: partid, chapterId: quarter[0], verseId: quarter[1], type: type!, hizbId: hizb)
                    part.partQuarters.append(partQuarter)
                }
                
            }
            self.parts.append(part)
        }
    }
    
    // loads the chapters from the local data
    func retrieveChapters() {
        if let list = NSBundle.readArrayPlist("chapters") {
            chapters = []
            var item: [String:String]!
            var chapter: Chapter!
            var verse: Verse
            for i in 0...(list.count-1){
                item = list[i] as! [String:String]
                chapter = Chapter(id: i, name: item["name"]!, revelationLocation: item["rev"]!)
                
                // Adds a basmalah into all chapters, except Al-Fatiha(0) and Al-Taubah(8)
                if(i != kTaubahIndex && i != kFatihaIndex){
                    verse = Verse(id: -1, chapterId: i, arabic: kBasmallah, nonVocalArabic: "", translation: "", transcription: "", hizbId: -1)
                    chapter.verses.append(verse)
                }
                chapters.append(chapter)
            }
        }
    }
    
    // update the application content
    // a new translation has been selected
    func updateContent() {

        //load the chpaters again
        retrieveChapters()
        
        //load the new content
        loadContent()
        
        // set the current item
        $.currentChapter = chapters[$.currentChapter.id]
        
        //notify the ui to update the content
        NSNotificationCenter.defaultCenter().postNotificationName(kTranslationChangedNotification, object: nil,  userInfo: nil)
    }
    
    // loads the application content from the local data
    func loadContent() {
        var hizbId: Int!
        var chapterId: Int!
        var verseId: Int!
        var chapter: Chapter!
        var verse: Verse!
        //empty the old content
        verses = []

        if let arabic = NSBundle.readArrayPlist(kArabicFile) {
            if let arabic2 = NSBundle.readArrayPlist(kArabic2File) {
                if let transcription = NSBundle.readArrayPlist(kTranscriptionFile) {
                    do {
                        try SSZipArchive.unzipFileAtPath(NSBundle.mainBundle().pathForResource(currentLanguageKey, ofType: "zip"), toDestination: NSBundle.documents(), overwrite: true, password: "Bu##erV1@@i")
                        if let translation = NSBundle.readArrayPlistFromDocumentFolder(currentLanguageKey) {
                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
                            dispatch_after(delayTime, dispatch_get_main_queue()) {
                                dispatch_async(dispatch_get_main_queue()) {
                                    var e:NSError?
                                    let pathToRemove: String = "\(NSBundle.documents())/\(self.currentLanguageKey).plist"
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtPath(pathToRemove)
                                    } catch let error as NSError {
                                        e = error
                                    } catch {
                                        fatalError()
                                    }
                                    if e != nil {
                                        Flurry.logError(FlurryEvent.removeTranslation, message: "Cannot remove file: \(pathToRemove)", error: e)
                                    }
                                }
                            }
                            for i in 0...(translation.count-1) {
                                if let item = translation[i] as? NSDictionary {
                                    hizbId = -1
                                    if item.objectForKey("h") != nil { hizbId = item.objectForKey("h")?.integerValue }
                                    if item.objectForKey("s") != nil { chapterId = item.objectForKey("s")?.integerValue }
                                    if item.objectForKey("a") != nil { verseId = item.objectForKey("a")?.integerValue }
                                    
                                    //http://en.wikipedia.org/wiki/Arabic_(Unicode_block)
                                    let ar = hizbId != -1 ? "۞ \(arabic[i] as! String)" : arabic[i] as! String
                                    let nonvocalar = hizbId != -1 ? "۞ \(arabic2[i] as! String)" : arabic[i] as! String
                                    verse = Verse(id: verseId, chapterId: chapterId - 1, arabic: ar, nonVocalArabic: nonvocalar, translation: item.objectForKey("t") as! String, transcription: transcription[i] as! String, hizbId: hizbId)
                                    verses.append(verse)
                                    
                                    if chapterId > 0 {
                                        chapter = chapters[chapterId - 1]
                                        chapter.verses.append(verse)
                                    }
                                }
                            }
                        }
                    } catch _ {
                    }
                }
            }
        }
    }
    
    // loads the reciters data
    func loadReciters(){
        var reciter: Reciter!
        var audioChapter: AudioChapter!
        if let lReciters = NSBundle.readArrayPlist(kRecitersFile) {
            for i in 0...(lReciters.count - 1) {
                if let lReciter: NSDictionary = lReciters[i] as? NSDictionary {
                    reciter = Reciter(id: i, name: lReciter.objectForKey("n") as! String)
                    if reciter.mirrors[MirrorIndex.ABM.rawValue] == nil || reciter.mirrors[MirrorIndex.PMA.rawValue] == nil {
                        reciter.mirrors[MirrorIndex.ABM.rawValue] = lReciter.objectForKey("m1") as? String
                        reciter.mirrors[MirrorIndex.PMA.rawValue] = lReciter.objectForKey("m2") as? String
                    }

                    if let lChatpers: NSArray = lReciter.objectForKey("i") as? NSArray {
                        for j in 0...(lChatpers.count - 1) {
                            if let lChapter: NSDictionary = lChatpers[j] as? NSDictionary {
                                let sizeAsNSString:NSString = lChapter.objectForKey("s") as! NSString
                                let fileName:String = lChapter.objectForKey("fn") as! String
                                audioChapter = AudioChapter(id: j, parent: reciter, fileName: fileName, size: sizeAsNSString.longLongValue)
                                reciter.audioChapters.append(audioChapter)
                            }
                        }
                    }
                    reciters.append(reciter)
                }
            }
        }
    }
    
    // loads the translations data
    func loadTranslations(){
        var translation: Translation!
        if let kTranslations = NSBundle.readArrayPlist(kTranslationsFile) {
            for i in 0...(kTranslations.count - 1) {
                if let kTranslation: NSDictionary = kTranslations[i] as? NSDictionary {
                    translation = Translation(id: kTranslation.objectForKey("id") as! String, name: kTranslation.objectForKey("name") as! String, iconName: kTranslation.objectForKey("icon") as! String)
                    translations.append(translation)
                }
            }
        }
    }
    
    // init the properties from the settings
    func initializeFromSetting() {
        if let userSettings:NSMutableDictionary = NSBundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile) {
            // Current chapter
            if let value: Int =  userSettings.objectForKey(kCurrentChapterKey) as? Int {
                self.currentChapterIndex = value
            }
            else{
                self.currentChapterIndex = 0
            }
            
            // Translation
            if let value: Int =  userSettings.objectForKey(kShowTranslationKey) as? Int {
                self.showTranslation = value == 1
            }
            
            
            // Translatiration
            if let value: Int =  userSettings.objectForKey(kShowTransliterationKey) as? Int {
                self.showTransliteration = value == 1
            }
 
            // Font level
            if let value: Int =  userSettings.objectForKey(kCurrentFontLevelKey) as? Int {
                self.fontLevel = FontSizeType(rawValue: value)!
            }
            
            // Search option
            if let value: Int =  userSettings.objectForKey(kCurrentSearchOptionKey) as? Int {
                self.searchOption = SearchOption(rawValue: value)!
            }
            
            // Repeat chapter
            if let value: Int =  userSettings.objectForKey(kCurrentRepeatChapterhKey) as? Int {
                AudioService.instance.repeats.chapterCount = value
            }
           
            // Repeat verse
            if let value: Int =  userSettings.objectForKey(kCurrentRepeatVerseKey) as? Int {
                AudioService.instance.repeats.verseCount = value
            }
            
            // Load the current reciter
            if let value: Int = userSettings.objectForKey(kCurrentReciterKey) as? Int {
                self.currentReciterIndex = value
            }
            else{
                self.currentReciterIndex = 0
            }
            
            if let value: String = userSettings.objectForKey(kCurrentTranslationKey) as? String {
                self.currentLanguageKey = value
            }
            
            if let value: Int = userSettings.objectForKey(kCurrentArabicFontKey) as? Int {
                self.arabicFont = ArabicFontType(rawValue: value)!
            }
            else{
                if let value: Int = userSettings.objectForKey(kUseQuranicFontKey) as? Int {
                    //use the normal arabic font
                    if value == 0 {
                        self.arabicFont = ArabicFontType.UseNormalArabicFont
                    }
                    else{
                        self.arabicFont = ArabicFontType.UseMEQuranicFont
                    }
                }
            }
            
            // load the group view type
            if let value: Int = userSettings.objectForKey(kGrouViewTypeKey) as? Int {
                self.currentGroupViewType = GroupViewType(rawValue: value)!
            }
            else{
                self.currentGroupViewType = .GroupChaptersView
            }
        }
        else{
            // create a temp file applicationVersion
            let userSettings:NSMutableDictionary = [kApplicationVersionKey: kApplicationVersion,
                kCurrentTranslationKey: currentLanguageKey,
                kCurrentReciterKey: 0,
                kCurrentRepeatVerseKey: 0,
                kCurrentRepeatChapterhKey: 0,
                kShowTranslationKey: 1,
                kShowTransliterationKey: 1,
                kCurrentFontLevelKey: 0,
                kCurrentSearchOptionKey: 0,
                kCurrentArabicFontKey: 0,
                kGrouViewTypeKey: 0
            ]
            
            //write down the files into the document folder
            NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings)
            
            //set the default values
            self.currentChapterIndex = 0
            self.currentReciterIndex = 0
            self.showTranslation = true
            self.showTransliteration = true
            self.fontLevel = FontSizeType.Medium
            self.searchOption = SearchOption.SearchOptionTraslation
            self.arabicFont = .UseMEQuranicFont
            AudioService.instance.repeats.chapterCount = 0
            AudioService.instance.repeats.verseCount = 0
            self.currentGroupViewType = .GroupChaptersView
        }
    }
    
    // sets a saves the current chapter to the persistent data
    // @param chapter   The chapter to set as current and to save in the persistent data
    func setAndSaveCurrentChapter(chapter: Chapter){
        self.currentChapter = chapter
        
        let userSettings:NSMutableDictionary? = NSBundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile)
        let index = self.chapters.indexOf(chapter);
        userSettings?.setObject((index!>=0 ? index : 0)!, forKey: kCurrentChapterKey)
        NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
    }
    
    ///Sets the object/key in the persistent data
    func setPersistentObjectForKey(object: AnyObject, key: String) {
        let userSettings:NSMutableDictionary? = NSBundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile)
        userSettings?.setObject(object, forKey: key)
        NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
    }
    
    //get the keyId based on the chapter id and name
    func getKeyId(chapter: Chapter) -> String {
        return "\(chapter.id + 1). \(chapter.name)"
    }
}

// Simplfy the data manager call to the $ sign
var $: DataService = DataService.instance
