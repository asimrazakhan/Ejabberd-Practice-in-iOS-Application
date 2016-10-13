//
//  Message.h
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
enum MessageStatus : Int {
    case Sending
    case Sent
    case Received
    case Read
    case Failed
}

enum MessageSender : Int {
    case Myself
    case Someone
}

//
// This class is the message object itself
//
class Message: NSObject {
    var sender = MessageSender()
    var status = MessageStatus()
    var identifier = ""
    var chat_id = ""
    var text = ""
    var date: NSDate!
    var heigh: CGFloat = 0.0

    class func messageFromDictionary(dictionary: [NSObject : AnyObject]) -> Message {
        var message = Message()
        message.text = dictionary["text"]
        message.identifier = dictionary["message_id"]
        message.status = CInt(dictionary["status"]) + 1
        var dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            //Date in UTC
        var inputTimeZone = NSTimeZone.timeZoneWithAbbreviation("UTC")
        var inputDateFormatter = NSDateFormatter()
        inputDateFormatter.timeZone = inputTimeZone
        inputDateFormatter.dateFormat = dateFormat
        var date = inputDateFormatter.dateFromString(dictionary["sent"])!
            //Convert time in UTC to Local TimeZone
        var outputTimeZone = NSTimeZone.localTimeZone()
        var outputDateFormatter = NSDateFormatter()
        outputDateFormatter.timeZone = outputTimeZone
        outputDateFormatter.dateFormat = dateFormat
        var outputString = outputDateFormatter.stringFromDate(date)
        message.date! = outputDateFormatter.dateFromString(outputString)!
        return message
    }


    override init() {
        super.init()
        
        self.sender = .Myself
        self.status = .Sending
        self.text = ""
        self.heigh = 44
        self.date! = NSDate()
        self.identifier = ""
    
    }
}
//
//  Message.m
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//