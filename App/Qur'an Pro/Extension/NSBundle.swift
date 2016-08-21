//
//  NSBundle.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension NSBundle {
    
    class func documents() -> String! {
        let dirs: [AnyObject] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return dirs[0] as? String
    }
    
    class func readPlist(filename: String, fromDocumentsFolder: Bool=false) -> AnyObject? {
        let plist:AnyObject?
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "plist") {
            let data: NSData?
            do {
                data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
            } catch  {
                data = nil
            }
            do {
                plist = try NSPropertyListSerialization.propertyListWithData(data!, options: NSPropertyListReadOptions.Immutable, format: nil)
                return plist
            } catch  {
                plist = nil
            }
        }
        return nil
    }
    
    class func readArrayPlist(filename: String) -> NSArray? {
        if let array: AnyObject? = readPlist(filename) {
            if let array = array as? NSArray? {
                return array
            }
            else{
                print("Loaded plist file '\(filename)' is not NSArray")
            }
        }
        return nil
    }
    
    class func readDictionayPlist(filename: String) -> NSDictionary? {
        if let dictinary: AnyObject? = readPlist(filename) {
            if let dictinary = dictinary as? NSDictionary? {
                return dictinary
            }
            else{
                print("Loaded plist file '\(filename)' is not NSDictionary")
            }
        }
        return nil
    }
    
    class func writeArrayPlistToDocumentFolder(filename filename: String, array: NSArray) {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        array.writeToFile(path, atomically:true)
    }
    
    class func readArrayPlistFromDocumentFolder(filename: String) -> NSArray? {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        if let array: NSArray = NSArray(contentsOfFile: path) {
            return array
        }
        return nil;
    }
    
    class func writeDictionaryPlistToDocumentFolder(filename filename: String, dictionary: NSMutableDictionary) {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        dictionary.writeToFile(path, atomically:true)
    }
    
    class func readDictionaryPlistFromDocumentFolder(filename: String) -> NSMutableDictionary? {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        if let dictionary: NSMutableDictionary = NSMutableDictionary(contentsOfFile: path) {
            return dictionary
        }
        return nil;
    }
}