//
//  MessageGateway.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
import Foundation

//
// this class is responsable to send message
// to server and notify status. It's also responsable
// to get messages in local storage.
//
class MessageGateway: NSObject {
    weak var delegate: MessageGatewayDelegate?
    var chat: Chat!

    class func sharedInstance() -> AnyObject {
        var sharedInstance: MessageGateway? = nil
        var onceToken: dispatch_once_t
        dispatch_once(onceToken, {() -> Void in
            sharedInstance = self.init()
        })
        return sharedInstance
    }

    func loadOldMessages() {
        var array = LocalStorage.sharedInstance().queryMessagesForChatID(self.chat.identifier)
        if self.delegate {
            self.delegate.gatewayDidReceiveMessages(array)
        }
        var unreadMessages = self.queryUnreadMessagesInArray(array)
        self.updateStatusToReadInArray(unreadMessages)
    }

    func sendMessage(message: Message) {
        //
        // Add here your code to send message to your server
        // When you receive the response, you should update message status
        // Now I'm just faking update message
        //
        LocalStorage.sharedInstance().storeMessage(message)
        self.fakeMessageUpdate(message)
        //TODO
    }

    func news() {
    }

    func dismiss() {
        self.delegate = nil
    }


    override init() {
        super.init()
        
        self.messages_to_send = [AnyObject]()
    
    }

    func updateStatusToReadInArray(unreadMessages: [AnyObject]) {
        var read_ids = [AnyObject]()
        for message: Message in unreadMessages {
            message.status = .Read
            read_ids.append(message.identifier)
        }
        self.chat.numberOfUnreadMessages = 0
        self.sendReadStatusToMessages(read_ids)
    }

    func queryUnreadMessagesInArray(array: [AnyObject]) -> [AnyObject] {
        var predicate = NSPredicate(format: "SELF.status == %d", .Received)
        return (array as NSArray).filteredArrayUsingPredicate(predicate)
    }

    func fakeMessageUpdate(message: Message) {
        self.performSelector(#selector(self.updateMessageStatus), withObject: message, afterDelay: 2.0)
    }

    func updateMessageStatus(message: Message) {
        if message.status == .Sending {
            message.status = .Failed
        }
        else if message.status == .Failed {
            message.status = .Sent
        }
        else if message.status == .Sent {
            message.status = .Received
        }
        else if message.status == .Received {
            message.status = .Read
        }

        if self.delegate && self.delegate.respondsToSelector(#selector(self.gatewayDidUpdateStatusForMessage)) {
            self.delegate.gatewayDidUpdateStatusForMessage(message)
        }
        //
        // Remove this when connect to your server
        // fake update message
        //
        if message.status != .Read {
            self.fakeMessageUpdate(message)
        }
    }
// MARK: - Exchange data with API

    func sendReadStatusToMessages(message_ids: [AnyObject]) {
        if message_ids.count == 0 {
            return
        }
        //TODO
    }

    func sendReceivedStatusToMessages(message_ids: [AnyObject]) {
        if message_ids.count == 0 {
            return
        }
        //TODO
    }

    var messages_to_send = [AnyObject]()
}
protocol MessageGatewayDelegate: NSObject {
    func gatewayDidUpdateStatusForMessage(message: Message)

    func gatewayDidReceiveMessages(array: [AnyObject])
}
//
//  MessageGateway.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/4/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//