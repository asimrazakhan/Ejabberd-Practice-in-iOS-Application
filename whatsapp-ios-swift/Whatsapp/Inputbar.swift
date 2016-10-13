//
//  Inputbar.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/11/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
//
// Thanks for HansPinckaers for creating an amazing
// Growing UITextView. This class just add design and
// notifications to uitoobar be similar to whatsapp
// inputbar.
//
// https://github.com/HansPinckaers/GrowingTextView
//

class Inputbar: UIToolbar {
    weak var delegate: InputbarDelegate?
    var placeholder: String {
        get {
            // TODO: add getter implementation
        }
        set(placeholder) {
            self.placeholder = placeholder
            self.textView.placeholder = placeholder
        }
    }
    var leftButtonImage: UIImage? {
        get {
            // TODO: add getter implementation
        }
        set(leftButtonImage) {
            self.leftButton.setImage(leftButtonImage, forState: .Normal)
        }
    }
    var rightButtonText: String {
        get {
            // TODO: add getter implementation
        }
        set(rightButtonText) {
            self.rightButton.setTitle(rightButtonText, forState: .Normal)
        }
    }
    var rightButtonTextColor: UIColor? {
        get {
            // TODO: add getter implementation
        }
        set(righButtonTextColor) {
            self.rightButton.setTitleColor(righButtonTextColor, forState: .Normal)
        }
    }

    override func resignFirstResponder() {
        textView.resignFirstResponder()
    }

    override func text() -> String {
        return textView.text
    }


    override init() {
        super.init()
        
        self.addContent()
    
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        do {
            self.addContent()
        }
    }

    convenience required init?(coder aDecoder: NSCoder) {
        if (super.init(coder: aDecoder)) {
            self.addContent()
        }
    }

    func addContent() {
        self.addTextView()
        self.addRightButton()
        self.addLeftButton()
        self.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
    }

    func addTextView() {
        var size = self.frame.size
        self.textView = HPGrowingTextView(frame: CGRectMake(LEFT_BUTTON_SIZE, 5, size.width - LEFT_BUTTON_SIZE - RIGHT_BUTTON_SIZE, size.height))
        self.textView.isScrollable = false
        self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        self.textView.minNumberOfLines = 1
        self.textView.maxNumberOfLines = 6
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
        self.textView.returnKeyType = UIReturnKeyGo
        //just as an example
        self.textView.font = UIFont.systemFontOfSize(15.0)
        self.textView.delegate! = self
        self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0)
        self.textView.backgroundColor = UIColor.whiteColor()
        self.textView.placeholder = placeholder
        //textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.textView.keyboardType = .Default
        self.textView.returnKeyType = UIReturnKeyDefault
        self.textView.enablesReturnKeyAutomatically = true
        //textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
        //textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
        self.textView.layer.cornerRadius = 5.0
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0).CGColor
        self.textView.autoresizingMask = .FlexibleWidth
        // view hierachy
        self.addSubview(textView)
    }

    func addRightButton() {
        var size = self.frame.size
        self.rightButton = UIButton()
        self.rightButton.frame = CGRectMake(size.width - RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE, size.height)
        self.rightButton.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin]
        self.rightButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        self.rightButton.setTitleColor(UIColor.lightGrayColor(), forState: .Selected)
        self.rightButton.setTitle("Done", forState: .Normal)
        self.rightButton.titleLabel!.font = UIFont(name: "Helvetica", size: 15.0)
        self.rightButton.addTarget(self, action: #selector(self.didPressRightButton), forControlEvents: .TouchUpInside)
        self.addSubview(self.rightButton)
        self.rightButton.selected = true
    }

    func addLeftButton() {
        var size = self.frame.size
        self.leftButton = UIButton()
        self.leftButton.frame = CGRectMake(0, 0, LEFT_BUTTON_SIZE, size.height)
        self.leftButton.autoresizingMask = [.FlexibleTopMargin, .FlexibleRightMargin]
        self.leftButton.setImage(self.leftButtonImage, forState: .Normal)
        self.leftButton.addTarget(self, action: #selector(self.didPressLeftButton), forControlEvents: .TouchUpInside)
        self.addSubview(self.leftButton)
    }
// MARK: - Delegate

    func didPressRightButton(sender: UIButton) {
        if self.rightButton.isSelected {
            return
        }
        self.delegate.inputbarDidPressRightButton(self)
        self.textView.text = ""
    }

    func didPressLeftButton(sender: UIButton) {
        self.delegate.inputbarDidPressLeftButton(self)
    }
// MARK: - Set Methods
// MARK: - TextViewDelegate

    func growingTextView(growingTextView: HPGrowingTextView, willChangeHeight height: Float) {
        var diff: Float = (growingTextView.frame.size.height - height)
        var r = self.frame
        r.size.height -= diff
        r.origin.y += diff
        self.frame = r
        if self.delegate && self.delegate.respondsToSelector(#selector(self.inputbarDidChangeHeight)) {
            self.delegate.inputbarDidChangeHeight(self.frame.size.height)
        }
    }

    func growingTextViewDidBeginEditing(growingTextView: HPGrowingTextView) {
        if self.delegate && self.delegate.respondsToSelector(#selector(self.inputbarDidBecomeFirstResponder)) {
            self.delegate.inputbarDidBecomeFirstResponder(self)
        }
    }

    func growingTextViewDidChange(growingTextView: HPGrowingTextView) {
        var text = growingTextView.text.stringByReplacingOccurrencesOfString(" ", withString: "")
        if (text == "") {
            self.rightButton.selected = true
        }
        else {
            self.rightButton.selected = false
        }
    }

    var textView: HPGrowingTextView!
    var rightButton: UIButton!
    var leftButton: UIButton!
}
protocol InputbarDelegate: NSObject {
    func inputbarDidPressRightButton(inputbar: Inputbar)

    func inputbarDidPressLeftButton(inputbar: Inputbar)
    func inputbarDidChangeHeight(new_height: CGFloat)

    func inputbarDidBecomeFirstResponder(inputbar: Inputbar)
}
//
//  Inputbar.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/11/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

let RIGHT_BUTTON_SIZE = 60
let LEFT_BUTTON_SIZE = 45