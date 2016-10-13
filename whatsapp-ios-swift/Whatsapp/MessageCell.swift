//
//  MessageCell.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
//
// This class build bubble message cells
// for Income or Outgoing messages
//
class MessageCell: UITableViewCell {
    var message: Message? {
        get {
            // TODO: add getter implementation
        }
        set(message) {
            self.message = message
            self.buildCell()
            message.heigh = self.height
        }
    }
    var resendButton: UIButton!

    func updateMessageStatus() {
        self.buildCell()
        //Animate Transition
        self.statusIcon.alpha() = 0
        UIView.animateWithDuration(0.5, animations: {() -> Void in
            self.statusIcon.alpha() = 1
        })
    }
    //Estimate BubbleCell Height

    override func height() -> CGFloat {
        return bubbleImage.frame.size.height
    }

// MARK: -

    override init() {
        super.init()
        
        self.commonInit()
    
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.commonInit()
    
    }

    func commonInit() {
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.selectionStyle = .None
        self.accessoryType = .None
        self.textView = UITextView()
        self.bubbleImage = UIImageView()
        self.timeLabel = UILabel()
        self.statusIcon = UIImageView()
        self.resendButton = UIButton()
        self.resendButton.hidden = true
        self.contentView.addSubview(bubbleImage)
        self.contentView.addSubview(textView)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(statusIcon)
        self.contentView.addSubview(resendButton)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.textView.text = ""
        self.timeLabel.text! = ""
        self.statusIcon.image = nil
        self.bubbleImage.image = nil
        self.resendButton.hidden = true
    }

    func buildCell() {
        self.setTextView()
        self.setTimeLabel()
        self.setBubble()
        self.addStatusIcon()
        self.setStatusIcon()
        self.setFailedButton()
        self.setNeedsLayout()
    }
// MARK: - TextView

    func setTextView() {
        var max_witdh: CGFloat = 0.7 * self.contentView.frame.size.width
        self.textView.frame = CGRectMake(0, 0, max_witdh, MAXFLOAT)
        self.textView.font = UIFont(name: "Helvetica", size: 17.0)
        self.textView.backgroundColor = UIColor.clearColor()
        self.textView.userInteractionEnabled = false
        self.textView.text = message!.text
        textView.sizeToFit()
        var textView_x: CGFloat
        var textView_y: CGFloat
        var textView_w: CGFloat = textView.frame.size.width
        var textView_h: CGFloat = textView.frame.size.height
        var autoresizing: UIViewAutoresizing
        if message!.sender == .Myself {
            textView_x = self.contentView.frame.size.width - textView_w - 20
            textView_y = -3
            autoresizing = .FlexibleLeftMargin
            textView_x -= self.isSingleLineCase() ? 65.0 : 0.0
            textView_x -= self.isStatusFailedCase() ? (self.fail_delta() - 15) : 0.0
        }
        else {
            textView_x = 20
            textView_y = -1
            autoresizing = .FlexibleRightMargin
        }
        self.textView.autoresizingMask = autoresizing
        self.textView.frame = CGRectMake(textView_x, textView_y, textView_w, textView_h)
    }
// MARK: - TimeLabel

    func setTimeLabel() {
        self.timeLabel.frame = CGRectMake(0, 0, 52, 14)
        self.timeLabel.textColor = UIColor.lightGrayColor()
        self.timeLabel.font = UIFont(name: "Helvetica", size: 12.0)
        self.timeLabel.userInteractionEnabled = false
        self.timeLabel.alpha() = 0.7
        self.timeLabel.textAlignment = .Right
            //Set Text to Label
        var df = NSDateFormatter()
        df.timeStyle = NSDateFormatterShortStyle
        df.dateStyle = NSDateFormatterNoStyle
        df.doesRelativeDateFormatting = true
        self.timeLabel.text! = df.stringFromDate(message!.date!)
            //Set position
        var time_x: CGFloat
        var time_y: CGFloat = textView.frame.size.height - 10
        if message!.sender == .Myself {
            time_x = textView.frame.origin.x + textView.frame.size.width - timeLabel.frame.size.width - 20
        }
        else {
            time_x = max(textView.frame.origin.x + textView.frame.size.width - timeLabel.frame.size.width, textView.frame.origin.x)
        }
        if self.isSingleLineCase() {
            time_x = textView.frame.origin.x + textView.frame.size.width - 5
            time_y -= 10
        }
        self.timeLabel.frame = CGRectMake(time_x, time_y, timeLabel.frame.size.width, timeLabel.frame.size.height)
        self.timeLabel.autoresizingMask = textView.autoresizingMask
    }

    func isSingleLineCase() -> Bool {
        var delta_x: CGFloat = message!.sender == .Myself ? 65.0 : 44.0
        var textView_height: CGFloat = textView.frame.size.height
        var textView_width: CGFloat = textView.frame.size.width
        var view_width: CGFloat = self.contentView.frame.size.width
        //Single Line Case
        return (textView_height <= 45 && textView_width + delta_x <= 0.8 * view_width) ? true : false
    }
// MARK: - Bubble

    func setBubble() {
            //Margins to Bubble
        var marginLeft: CGFloat = 5
        var marginRight: CGFloat = 2
            //Bubble positions
        var bubble_x: CGFloat
        var bubble_y: CGFloat = 0
        var bubble_width: CGFloat
        var bubble_height: CGFloat = min(textView.frame.size.height + 8, timeLabel.frame.origin.y + timeLabel.frame.size.height + 6)
        if message!.sender == .Myself {
            bubble_x = min(textView.frame.origin.x - marginLeft, timeLabel.frame.origin.x - 2 * marginLeft)
            self.bubbleImage.image = UIImage(named: "bubbleMine")!.stretchableImageWithLeftCapWidth(15, topCapHeight: 14)
            bubble_width = self.contentView.frame.size.width - bubble_x - marginRight
            bubble_width -= self.isStatusFailedCase() ? self.fail_delta() : 0.0
        }
        else {
            bubble_x = marginRight
            self.bubbleImage.image = UIImage(named: "bubbleSomeone")!.stretchableImageWithLeftCapWidth(21, topCapHeight: 14)
            bubble_width = max(textView.frame.origin.x + textView.frame.size.width + marginLeft, timeLabel.frame.origin.x + timeLabel.frame.size.width + 2 * marginLeft)
        }
        self.bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height)
        self.bubbleImage.autoresizingMask = textView.autoresizingMask
    }
// MARK: - StatusIcon

    func addStatusIcon() {
        var time_frame = timeLabel.frame
        var status_frame = CGRectMake(0, 0, 15, 14)
        status_frame.origin.x = time_frame.origin.x + time_frame.size.width + 5
        status_frame.origin.y = time_frame.origin.y
        self.statusIcon.frame = status_frame
        self.statusIcon.contentMode = .Left
        self.statusIcon.autoresizingMask = textView.autoresizingMask
    }

    func setStatusIcon() {
        if self.message.status == .Sending {
            self.statusIcon.image = UIImage(named: "status_sending")!
        }
        else if self.message.status == .Sent {
            self.statusIcon.image = UIImage(named: "status_sent")!
        }
        else if self.message.status == .Received {
            self.statusIcon.image = UIImage(named: "status_notified")!
        }
        else if self.message.status == .Read {
            self.statusIcon.image = UIImage(named: "status_read")!
        }

        if self.message.status == .Failed {
            self.statusIcon.image = nil
        }
        self.statusIcon.hidden = message!.sender == .Someone
    }
// MARK: - Failed Case
    //
    // This delta is how much TextView
    // and Bubble should shit left
    //

    func fail_delta() -> Int {
        return 60
    }

    func isStatusFailedCase() -> Bool {
        return self.message.status == .Failed
    }

    func setFailedButton() {
        var b_size = 22
        var frame = CGRectMake(self.contentView.frame.size.width - b_size - self.fail_delta() / 2 + 5, (self.contentView.frame.size.height - b_size) / 2, b_size, b_size)
        self.resendButton.frame = frame
        self.resendButton.hidden = !self.isStatusFailedCase()
        resendButton.setImage(UIImage(named: "status_failed")!, forState: .Normal)
    }
// MARK: - UIImage Helper

    override func imageNamed(imageName: String) -> UIImage {
        return UIImage(named: imageName, inBundle: NSBundle(forClass: self.self), compatibleWithTraitCollection: nil)!
    }

    var timeLabel: UILabel!
    var textView: UITextView!
    var bubbleImage: UIImageView!
    var statusIcon: UIImageView!
}
//
//  MessageCell.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//