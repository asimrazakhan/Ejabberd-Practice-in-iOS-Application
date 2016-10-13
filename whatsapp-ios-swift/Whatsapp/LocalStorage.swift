//
//  LocalStorage.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
import Foundation
// This class is responsable to store messages
// For now, it stores in memory only
//
class LocalStorage: NSObject {
    class func sharedInstance() -> AnyObject {
        var sharedInstance: LocalStorage? = nil
        var onceToken: dispatch_once_t
        dispatch_once(onceToken, {() -> Void in
            sharedInstance = self.init()
        })
        return sharedInstance
    }

    class func storeChat(chat: Chat) {
        //TODO
    }

    class func storeChats(chats: [AnyObject]) {
        //TODO
    }

    class func storeContact(contact: Contact) {
        //TODO
    }

    class func storeContacts(contacts: [AnyObject]) {
        //TODO
    }

    class func storeMessage(message: Message) {
    }

    class func storeMessages(messages: [AnyObject]) {
    }

    func queryMessagesForChatID(chat_id: String) -> [AnyObject] {
        return (self.mapChatToMessages.valueForKey(chat_id) as! String)
    }


    override init() {
        super.init()
        
        self.mapChatToMessages = [NSObject : AnyObject]()
    
    }

    func storeMessage(message: Message) {
        self.storeMessages([message])
    }

    func storeMessages(messages: [AnyObject]) {
        if messages.count == 0 {
            return
        }
        var message = messages[0]
        var chat_id = message.chat_id
        var array = (self.queryMessagesForChatID(chat_id) as! [AnyObject])
        if !array.isEmpty {
            array += messages
        }
        else {
            array = [AnyObject](arrayLiteral: messages)
        }
        self.mapChatToMessages[chat_id] = array
    }

    var mapChatToMessages = [NSObject : AnyObject]()
}
//
//  LocalStorage.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//