//
//  MessageArray.h
//  Whatsapp
//
//  Created by Rafael Castro on 6/18/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
import Foundation
//
// This class teaches tableView how to interact with
// dictionaty. Basically it's mimics the array use in
// a tableView.
//
class TableArray: NSObject {
    override func addObject(message: Message) {
        return self.addMessage(message)
    }

    override func addObjectsFromArray(messages: [AnyObject]) {
        for message: Message in messages {
            self.addMessage(message)
        }
    }

    override func removeObject(message: Message) {
        self.removeMessage(message)
    }

    override func removeObjectsInArray(messages: [AnyObject]) {
        for message: Message in messages {
            self.removeMessage(message)
        }
    }

    override func removeAllObjects() {
        self.mapTitleToMessages.removeAll()
        self.orderedTitles = nil
    }

    func numberOfMessages() -> Int {
        return numberOfMessages
    }

    override func numberOfSections() -> Int {
        return numberOfSections
    }

    func numberOfMessagesInSection(section: Int) -> Int {
        if self.orderedTitles.count == 0 {
            return 0
        }
        var key = self.orderedTitles[section]
        var array = (self.mapTitleToMessages.valueForKey(key) as! String)
        return array.count
    }

    func titleForSection(section: Int) -> String {
        var formatter = self.formatter
        var key = self.orderedTitles[section]
        var date = formatter.dateFromString(key)!
        formatter.doesRelativeDateFormatting = true
        return formatter.stringFromDate(date)
    }

    override func objectAtIndexPath(indexPath: NSIndexPath) -> Message {
        var key = self.orderedTitles[indexPath.section]
        var array = (self.mapTitleToMessages.valueForKey(key) as! String)
        return array[indexPath.row]
    }

    override func lastObject() -> Message {
        var indexPath = self()
        return self.objectAtIndexPath(indexPath)
    }

    override func indexPathForLastMessage() -> NSIndexPath {
        var lastSection = numberOfSections - 1
        var numberOfMessages = self.numberOfMessagesInSection(lastSection)
        return NSIndexPath(forRow: numberOfMessages - 1, inSection: lastSection)
    }

    override func indexPathForMessage(message: Message) -> NSIndexPath {
        var key = self.keyForMessage(message)
        var section = self.orderedTitles.indexOf(key)
        var row = (self.mapTitleToMessages.valueForKey(key) as! String).indexOf(message)
        return NSIndexPath(forRow: row, inSection: section)
    }


    override init() {
        super.init()
        
        self.orderedTitles = [AnyObject]()
        self.mapTitleToMessages = [NSObject : AnyObject]()
    
    }
// MARK: - Helpers

    func addMessage(message: Message) {
        var key = self.keyForMessage(message)
        var array = (self.mapTitleToMessages.valueForKey(key) as! String)
        if array.isEmpty {
            self.numberOfSections += 1
            array = [AnyObject]()
        }
        array.append(message)
        var sortedArray = (array as NSArray).sortedArrayUsingComparator({(m1: Message, m2: Message) -> NSComparisonResult in
                return m1.date!.compare(m2.date!)
            })
        var result = [AnyObject](arrayLiteral: sortedArray)
        self.mapTitleToMessages[key] = result
        self.cacheTitles()
        self.numberOfMessages += 1
    }

    func removeMessage(message: Message) {
        var key = self.keyForMessage(message)
        var array = (self.mapTitleToMessages.valueForKey(key) as! String)
        if !array.isEmpty {
            array.removeAtIndex(array.indexOf(message)!)
            if array.count == 0 {
                self.numberOfSections -= 1
                self.mapTitleToMessages.removeValueForKey(key)
                self.cacheTitles()
            }
            else {
                self.mapTitleToMessages[key] = array
            }
            self.numberOfMessages -= 1
        }
    }

    func cacheTitles() {
        var array = self.mapTitleToMessages.allKeys()
        var orderedArray = (array as NSArray).sortedArrayUsingComparator({(dateString1: String, dateString2: String) -> NSComparisonResult in
                var d1 = self.formatter.dateFromString(dateString1)!
                var d2 = self.formatter.dateFromString(dateString2)!
                return d1.compare(d2)
            })
        self.orderedTitles = [AnyObject](arrayLiteral: orderedArray)
    }

    func keyForMessage(message: Message) -> String {
        return self.formatter.stringFromDate(message.date!)
    }

    func formatter() -> NSDateFormatter {
        if !formatter {
            self.formatter = NSDateFormatter()
            self.formatter.timeStyle = NSDateFormatterNoStyle
            self.formatter.dateStyle = NSDateFormatterShortStyle
            self.formatter.doesRelativeDateFormatting = false
        }
        return formatter
    }

    var mapTitleToMessages = [NSObject : AnyObject]()
    var orderedTitles = [AnyObject]()
    var numberOfSections: Int {
        return numberOfSections
    }
    var numberOfMessages: Int {
        return numberOfMessages
    }
    var formatter: NSDateFormatter? {
        if !formatter {
                self.formatter = NSDateFormatter()
                self.formatter.timeStyle = NSDateFormatterNoStyle
                self.formatter.dateStyle = NSDateFormatterShortStyle
                self.formatter.doesRelativeDateFormatting = false
            }
            return formatter
    }
}
//
//  MessageArray.m
//  Whatsapp
//
//  Created by Rafael Castro on 6/18/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//