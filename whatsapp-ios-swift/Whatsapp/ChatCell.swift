//
//  ChatListCell.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
//
// This class is the custom cell in
// ChatController
//
class ChatCell: UITableViewCell {
    var chat: Chat? {
        get {
            // TODO: add getter implementation
        }
        set(chat) {
            self.chat = chat
            self.nameLabel.text! = chat.contact.name
            self.messageLabel.text! = chat.last_message.text
            self.updateTimeLabelWithDate(chat.last_message.date!)
            self.updateUnreadMessagesIcon(chat.numberOfUnreadMessages)
        }
    }

    override func imageView() -> UIImageView {
        return picture
    }


    override func awakeFromNib() {
        self.picture.layer.cornerRadius = self.picture.frame.size.width / 2
        self.picture.layer.masksToBounds = true
        self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.width / 2
        self.notificationLabel.layer.masksToBounds = true
        self.nameLabel.text! = ""
        self.messageLabel.text! = ""
        self.timeLabel.text! = ""
    }

    func updateTimeLabelWithDate(date: NSDate) {
        var df = NSDateFormatter()
        df.timeStyle = NSDateFormatterShortStyle
        df.dateStyle = NSDateFormatterNoStyle
        df.doesRelativeDateFormatting = false
        self.timeLabel.text! = df.stringFromDate(date)
    }

    func updateUnreadMessagesIcon(numberOfUnreadMessages: Int) {
        self.notificationLabel.hidden = numberOfUnreadMessages == 0
        self.notificationLabel.text! = "\(Int(numberOfUnreadMessages))"
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
}
//
//  ChatListCell.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//