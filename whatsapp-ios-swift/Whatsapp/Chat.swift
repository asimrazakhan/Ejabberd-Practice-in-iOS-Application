//
//  Chat.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
import Foundation
//
// This class is responsable to store information
// displayed in ChatController
//
class Chat: NSObject {
    var last_message: Message? {
        get {
            // TODO: add getter implementation
        }
        set(last_message) {
            if !last_message {
                self.last_message = last_message
            }
            else {
                if last_message.date!.earlierDate(last_message.date!) == last_message.date! {
                    self.last_message = last_message
                }
            }
        }
    }
    var contact: Contact!
    var numberOfUnreadMessages = 0

    override func identifier() -> String {
        return contact.identifier
    }

    func save() {
        LocalStorage.storeChat(self)
    }
}
//
//  Chat.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//