//
//  AudioService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import AVFoundation
import MediaPlayer

struct Repeats {
    var verses = ["Play verse once".local, "Play verse twice".local, "Play 3 times".local, "Play 4 times".local, "Play 5 times".local, "Keep playing verse".local]
    var chapters = ["Play chapter by chapter".local, "Play chapter once".local, "Keep playing chapter".local]
    var verseCount: Int = 1
    var chapterCount: Int = 1
}

protocol AudioDelegate {
    func playNextChapter()
    func scrollToVerse(verseId: Int, searchText:String?)
}

class AudioService:NSObject, AVAudioPlayerDelegate {
    
    // Singlton instance
    class var instance: AudioService {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: AudioService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = AudioService()
        }
        return Static.instance!
    }
    
    //hold a reference to a delegate
    var delegate: AudioDelegate?
    var currentVerseIndex: Int!
    var isPaused: Bool!
    
    //hold the repeat verses and chapters string
    var repeats: Repeats!
    
    //hold the player instance
    private var player: AVAudioPlayer?
    
    override init(){
        super.init()
        self.isPaused = false
        self.repeats = Repeats()
        self.currentVerseIndex = 0
    }

    func initDelegation(delegate: AudioDelegate?){
        if delegate != nil {
            self.delegate = delegate
        }
    }
    
    //play the passed verse index
    //@param verseToPlay verse to play or the first one if nothing is passed
    func play(verseToPlay: Verse? = nil){
        // cute little demo
        let mpic = MPNowPlayingInfoCenter.defaultCenter();
        var dic = [String: AnyObject]()
        dic[MPMediaItemPropertyTitle] = kApplicationDisplayName
        dic[MPMediaItemPropertyArtist] = "\($.currentChapter.name) - \($.currentReciter.name)"
        dic[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named: "launch-screen")!)
        mpic.nowPlayingInfo = dic

        var verse: Verse!
        let audioChapter: AudioChapter = $.currentReciter.audioChapters[$.currentChapter.id]
        if verseToPlay == nil {
            verse = $.currentChapter.verses[0]
            self.currentVerseIndex = 0
        }
        else{
            verse = verseToPlay
            self.currentVerseIndex = $.currentChapter.verses.indexOf(verse)
        }
        
        delegate?.scrollToVerse(self.currentVerseIndex, searchText: "")
        
        let path: String  = audioChapter.verseAudioPath(verse)
        let url:NSURL = NSURL(fileURLWithPath: path, isDirectory: false)
        var error: NSError?
        
        //remove the old player if exist
        self.isPaused = false
        
        // create a new instance of the player the new data
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
        } catch let error1 as NSError {
            error = error1
        }
        self.player?.prepareToPlay()
        self.player?.delegate = self
        //set the number of loops
        self.player?.numberOfLoops = self.repeats.verseCount
        
        // if no error were found, play the verse
        if error == nil {
            self.player?.play()
            self.isPaused = false
        }
    }
    
    //rest the player
    private func resetPlayer() {
        self.player?.stop()
        self.player?.delegate = nil
        //self.player = nil
        self.isPaused = false
    }
    
    // MARK: AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        // start spalying the first verses
        if currentVerseIndex < $.currentChapter.verses.count - 1 {
            currentVerseIndex = currentVerseIndex + 1
            play($.currentChapter.verses[currentVerseIndex])
        }
        //all verses has been played, check what to do next
        else{
            currentVerseIndex = 0
            resetPlayer()
            
            //case: 'Play chapter by chapter'
            //check if we can play the next chapter
            if self.repeats.chapterCount == 0 {
                //ask the delegate if we can play the next chapter
                delegate?.playNextChapter()
            }
            //case: 'Play chapter once'
            else if self.repeats.chapterCount == 1 {
                // do nothing, just stop here...
            }
            //case: 'Keep playing chapter'
            else if self.repeats.chapterCount == 2 {
                play()
            }
        }
    }
    
    // MARK: Utils
    
    // resume playing the current audio
    func resumePlaying() {
        if self.isPaused == true {
            self.player?.play()
            self.isPaused = false
        }
        else{
            play()
        }
    }
    
    // pause playing the current audio
    func pausePlaying() {
        self.isPaused = true
        self.player?.pause()
    }
    
    // play the next audio if any
    func playNext() {
        let total = $.currentChapter.verses.count
        if currentVerseIndex < total - 1 {
            currentVerseIndex = currentVerseIndex + 1
            play($.currentChapter.verses[currentVerseIndex])
            self.isPaused = false
        }
    }
    
    // play the previous audio if any
    func playPrevious() {
        if currentVerseIndex > 0 {
            currentVerseIndex = currentVerseIndex - 1
            play($.currentChapter.verses[currentVerseIndex])
            self.isPaused = false
        }
    }
    
    // update the current played audio with the corrent numberOfLoops
    func repeatPlay() {
        //Case: "Keep playing verse"
        if repeats.verseCount == repeats.verses.count - 2 {
            repeats.verseCount = -1
        }
        //other cases
        else{
            repeats.verseCount = repeats.verseCount + 1
        }
        
        //set the number of loops
        self.player?.numberOfLoops = repeats.verseCount
        
        //save the repeat value of the disk
        $.setPersistentObjectForKey(repeats.verseCount, key: kCurrentRepeatVerseKey)
        NSNotificationCenter.defaultCenter().postNotificationName(kRepatCountChangedNotification, object: nil,  userInfo: nil)
    }
    
    // stops and resets the player
    func stopAndReset() {
        resetPlayer()
    }
    
    // check whether the audio is played or not
    func isPlaying() -> Bool{
        return self.player != nil && self.player!.playing
    }
    
    // get the icon name of the repeat control
    func repeatIconName() -> String {
        if repeats.verseCount == -1 {
            return "repeat-∞"
        }
        else{
            return "repeat-\(repeats.verseCount + 1)"
        }
    }
    
    deinit {
        self.player?.delegate = nil
        self.player = nil
    }
}