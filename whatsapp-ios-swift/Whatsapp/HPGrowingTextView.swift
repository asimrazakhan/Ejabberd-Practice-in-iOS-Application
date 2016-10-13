//
//  HPTextView.h
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
import UIKit
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
// UITextAlignment is deprecated in iOS 6.0+, use NSTextAlignment instead.
// Reference: https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
let NSTextAlignment = UITextAlignment
#endif

protocol HPGrowingTextViewDelegate: class {
    func growingTextViewShouldBeginEditing(growingTextView: HPGrowingTextView) -> Bool

    func growingTextViewShouldEndEditing(growingTextView: HPGrowingTextView) -> Bool

    func growingTextViewDidBeginEditing(growingTextView: HPGrowingTextView)

    func growingTextViewDidEndEditing(growingTextView: HPGrowingTextView)

    func growingTextView(growingTextView: HPGrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool

    func growingTextViewDidChange(growingTextView: HPGrowingTextView)

    func growingTextView(growingTextView: HPGrowingTextView, willChangeHeight height: CGFloat)

    func growingTextView(growingTextView: HPGrowingTextView, didChangeHeight height: CGFloat)

    func growingTextViewDidChangeSelection(growingTextView: HPGrowingTextView)

    func growingTextViewShouldReturn(growingTextView: HPGrowingTextView) -> Bool
}
class HPGrowingTextView: UIView, UITextViewDelegate {
    //class properties

    //uitextview properties

    var dataDetectorTypes = UIDataDetectorTypes()

    //real class properties
    var maxNumberOfLines = 0
    var minNumberOfLines = 0
    var maxHeight = 0
    var minHeight = 0
    var animateHeightChange = false
    var animationDuration = NSTimeInterval()
    var placeholder = ""
    var placeholderColor: UIColor!
    var internalTextView: UITextView!
    //uitextview properties
    weak var delegate: HPGrowingTextViewDelegate?
    var text = ""
    var font: UIFont!
    var textColor: UIColor!
    var textAlignment = NSTextAlignment()
    // default is NSTextAlignmentLeft
    var selectedRange = NSRange()
    // only ranges of length 0 are supported
    var editable = false
    var = UIDataDetectorTypes dataDetectorTypes()
    __OSX_AVAILABLE_STARTING(__MAC_NA)
    var returnKeyType = UIReturnKeyType()
    var keyboardType = UIKeyboardType()
    var contentInset = UIEdgeInsets()
    var isScrollable = false
    var enablesReturnKeyAutomatically = false
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

    convenience override init(frame: CGRect, textContainer: NSTextContainer) {
        if (super.init(frame: frame)) {
            self.commonInitialiser(textContainer)
        }
    }
#endif
    //uitextview methods
    //need others? use .internalTextView

    override func becomeFirstResponder() -> Bool {
    }

    override func resignFirstResponder() -> Bool {
    }

    override func isFirstResponder() -> Bool {
    }

    override func hasText() -> Bool {
    }

    override func scrollRangeToVisible(range: NSRange) {
    }
    // call to force a height change (e.g. after you change max/min lines)

    func refreshHeight() {
    }

    // having initwithcoder allows us to use HPGrowingTextView in a Nib. -- aob, 9/2011

    convenience required init?(coder aDecoder: NSCoder) {
        if (super.init(coder: aDecoder)) {
            self.commonInitialiser()
        }
    }

    convenience override init(frame: CGRect) {
        if (super.init(frame: frame)) {
            self.commonInitialiser()
        }
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

    func commonInitialiser() {
        self.commonInitialiser(nil)
    }

    func commonInitialiser(textContainer: NSTextContainer) {
#else
        -
        var commonInitialiser
#endif
        do {
                // Initialization code
            var r = self.frame
            r.origin.y = 0
            r.origin.x = 0
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
            internalTextView = HPTextViewInternal(frame: r, textContainer: textContainer)
#else
            internalTextView = HPTextViewInternal(frame: r)
#endif
            internalTextView.delegate = self
            internalTextView.scrollEnabled = false
            internalTextView.font = UIFont(name: "Helvetica", size: 13)
            internalTextView.contentInset = UIEdgeInsetsZero
            internalTextView.showsHorizontalScrollIndicator = false
            internalTextView.text = "-"
            internalTextView.contentMode = .Redraw
            self.addSubview(internalTextView)
            minHeight = internalTextView.frame.size.height
            minNumberOfLines = 1
            animateHeightChange = true
            animationDuration = 0.1
            internalTextView.text = ""
            self.maxNumberOfLines = 3
            self.placeholderColor = UIColor.lightGrayColor()
            internalTextView.displayPlaceHolder = true
        }
        -
    }
}
//
//  HPTextView.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
extension HPGrowingTextView {
    func commonInitialiser() {
    }

    func resizeTextView(newSizeH: Int) {
    }

    func growDidStop() {
    }
}
func size() {
    if self.text.characters.count == 0 {
        size.height = minHeight
    }
    return size
}

func layoutSubviews() {
    super.layoutSubviews()
    var r = self.bounds
    r.origin.y = 0
    r.origin.x = contentInset.left
    r.size.width -= contentInset.left + contentInset.right
    internalTextView.frame = r
}

func inset() {
    contentInset = inset
    var r = self.frame
    r.origin.y = inset.top - inset.bottom
    r.origin.x = inset.left
    r.size.width -= inset.left + inset.right
    internalTextView.frame = r
    self.maxNumberOfLines = maxNumberOfLines
    self.minNumberOfLines = minNumberOfLines
}

func contentInset() {
    return contentInset
}

func n() {
    if n == 0 && maxHeight > 0 {
        return
    }
        // the user specified a maxHeight themselves.
        // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    var saveText = internalTextView.text
    var newText = "-"
    internalTextView.delegate = nil
    internalTextView.hidden = true
    for i in 1..<n {
        newText = newText.stringByAppendingString("\n|W|")
    }
    internalTextView.text = newText
    maxHeight = self.measureHeight()
    internalTextView.text = saveText
    internalTextView.hidden = false
    internalTextView.delegate = self
    self.sizeToFit()
    maxNumberOfLines = n
}

func maxNumberOfLines() {
    return maxNumberOfLines
}

func height() {
    maxHeight = height
    maxNumberOfLines = 0
}

func m() {
    if m == 0 && minHeight > 0 {
        return
    }
        // the user specified a minHeight themselves.
        // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    var saveText = internalTextView.text
    var newText = "-"
    internalTextView.delegate = nil
    internalTextView.hidden = true
    for i in 1..<m {
        newText = newText.stringByAppendingString("\n|W|")
    }
    internalTextView.text = newText
    minHeight = self.measureHeight()
    internalTextView.text = saveText
    internalTextView.hidden = false
    internalTextView.delegate = self
    self.sizeToFit()
    minNumberOfLines = m
}

func minNumberOfLines() {
    return minNumberOfLines
}

func height() {
    minHeight = height
    minNumberOfLines = 0
}

func placeholder() {
    return internalTextView.placeholder
}

func placeholder() {
    internalTextView.placeholder = placeholder
    internalTextView.setNeedsDisplay()
}

func placeholderColor() {
    return internalTextView.placeholderColor
}

func placeholderColor() {
    internalTextView.placeholderColor = placeholderColor
}

func textView() {
    self.refreshHeight()
}

func refreshHeight() {
        //size of content, so we can set the frame of self
    var newSizeH = self.measureHeight()
    if newSizeH < minHeight || !internalTextView.hasText() {
        newSizeH = minHeight
        //not smalles than minHeight
    }
    else if maxHeight && newSizeH > maxHeight {
        newSizeH = maxHeight
        // not taller than maxHeight
    }

    if internalTextView.frame.size.height != newSizeH {
        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
        if newSizeH >= maxHeight {
            if !internalTextView.scrollEnabled {
                internalTextView.scrollEnabled = true
                internalTextView.flashScrollIndicators()
            }
        }
        else {
            internalTextView.scrollEnabled = false
        }
        // [fixed] Pasting too much text into the view failed to fire the height change,
        // thanks to Gwynne <http://blog.darkrainfall.org/>
        if newSizeH <= maxHeight {
            if animateHeightChange {
                if UIView.resolveClassMethod(Selector("animateWithDuration:animations:")) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                    UIView.animateWithDuration(animationDuration, delay: 0, options: ([.AllowUserInteraction, .BeginFromCurrentState]), animations: {() -> Void in
                        self.resizeTextView(newSizeH)
                    }, completion: {(finished: Bool) -> Void in
                        if delegate!.respondsToSelector(Selector("growingTextView:didChangeHeight:")) {
                            delegate!.growingTextView(self, didChangeHeight: newSizeH)
                        }
                    })
#endif
                }
                else {
                    UIView.beginAnimations("", context: nil)
                    UIView.animationDuration = animationDuration
                    UIView.animationDelegate = self
                    UIView.animationDidStopSelector = #selector(self.growDidStop)
                    UIView.animationBeginsFromCurrentState = true
                    self.resizeTextView(newSizeH)
                    UIView.commitAnimations()
                }
            }
            else {
                self.resizeTextView(newSizeH)
                // [fixed] The growingTextView:didChangeHeight: delegate method was not called at all when not animating height changes.
                // thanks to Gwynne <http://blog.darkrainfall.org/>
                if delegate!.respondsToSelector(Selector("growingTextView:didChangeHeight:")) {
                    delegate!.growingTextView(self, didChangeHeight: newSizeH)
                }
            }
        }
    }
        // Display (or not) the placeholder string
    var wasDisplayingPlaceholder = internalTextView.displayPlaceHolder
    internalTextView.displayPlaceHolder = self.internalTextView.text.characters.count == 0
    if wasDisplayingPlaceholder != internalTextView.displayPlaceHolder {
        internalTextView.setNeedsDisplay()
    }
    // scroll to caret (needed on iOS7)
    if self.respondsToSelector(#selector(self.snapshotViewAfterScreenUpdates)) {
        self.performSelector(#selector(self.resetScrollPositionForIOS7), withObject: nil, afterDelay: 0.1)
    }
    // Tell the delegate that the text view changed
    if delegate!.respondsToSelector(#selector(self.growingTextViewDidChange)) {
        delegate!.growingTextViewDidChange(self)
    }
}

func measureHeight() {
    if self.respondsToSelector(#selector(self.snapshotViewAfterScreenUpdates)) {
        return ceilf(self.internalTextView.sizeThatFits(self.internalTextView.frame.size).height)
    }
    else {
        return self.internalTextView.contentSize.height
    }
}

func resetScrollPositionForIOS7() {
    var r = internalTextView.caretRectForPosition(internalTextView.selectedTextRange!.end)
    var caretY: CGFloat = max(r.origin.y - internalTextView.frame.size.height + r.size.height + 8, 0)
    if internalTextView.contentOffset.y < caretY && r.origin.y != .infinity {
        internalTextView.contentOffset = CGPointMake(0, caretY)
    }
}

func newSizeH() {
    if delegate!.respondsToSelector(Selector("growingTextView:willChangeHeight:")) {
        delegate!.growingTextView(self, willChangeHeight: newSizeH)
    }
    var internalTextViewFrame = self.frame
    internalTextViewFrame.size.height = newSizeH
    // + padding
    self.frame = internalTextViewFrame
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom
    internalTextViewFrame.origin.x = contentInset.left
    if !CGRectEqualToRect(internalTextView.frame, internalTextViewFrame) {
        internalTextView.frame = internalTextViewFrame
    }
}

func growDidStop() {
    // scroll to caret (needed on iOS7)
    if self.respondsToSelector(#selector(self.snapshotViewAfterScreenUpdates)) {
        self.resetScrollPositionForIOS7()
    }
    if delegate!.respondsToSelector(Selector("growingTextView:didChangeHeight:")) {
        delegate!.growingTextView(self, didChangeHeight: self.frame.size.height)
    }
}

func event() {
    internalTextView.becomeFirstResponder()
}

func becomeFirstResponder() {
    super.becomeFirstResponder()
    return self.internalTextView.becomeFirstResponder()
}

func resignFirstResponder() {
    super.resignFirstResponder()
    return internalTextView.resignFirstResponder()
}

func isFirstResponder() {
    return self.internalTextView.isFirstResponder()
}

func newText() {
    internalTextView.text = newText
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    self.performSelector(#selector(self.textViewDidChange), withObject: internalTextView)
}

func text() {
    return internalTextView.text
}

func afont() {
    internalTextView.font = afont
    self.maxNumberOfLines = maxNumberOfLines
    self.minNumberOfLines = minNumberOfLines
}

func font() {
    return internalTextView.font
}

func color() {
    internalTextView.textColor = color
}

func textColor() {
    return internalTextView.textColor
}

func backgroundColor() {
    super.backgroundColor = backgroundColor
    internalTextView.backgroundColor = backgroundColor
}

func backgroundColor() {
    return internalTextView.backgroundColor
}

func aligment() {
    internalTextView.textAlignment = aligment
}

func textAlignment() {
    return internalTextView.textAlignment
}

func range() {
    internalTextView.selectedRange = range
}

func selectedRange() {
    return internalTextView.selectedRange
}

func isScrollable() {
    internalTextView.scrollEnabled = isScrollable
}

func isScrollable() {
    return internalTextView.scrollEnabled
}

func beditable() {
    internalTextView.editable = beditable
}

func isEditable() {
    return internalTextView.editable
}

func keyType() {
    internalTextView.returnKeyType = keyType
}

func returnKeyType() {
    return internalTextView.returnKeyType
}

func keyType() {
    internalTextView.keyboardType = keyType
}

func keyboardType() {
    return internalTextView.keyboardType
}

func enablesReturnKeyAutomatically() {
    internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
}

func enablesReturnKeyAutomatically() {
    return internalTextView.enablesReturnKeyAutomatically
}

func datadetector() {
    internalTextView.dataDetectorTypes = datadetector
}

func dataDetectorTypes() {
    return internalTextView.dataDetectorTypes
}

func hasText() {
    return internalTextView.hasText()
}

func range() {
    internalTextView.scrollRangeToVisible(range)
}

func textView() {
    if delegate!.respondsToSelector(#selector(self.growingTextViewShouldBeginEditing)) {
        return delegate!.growingTextViewShouldBeginEditing(self)
    }
    else {
        return true
    }
}

func textView() {
    if delegate!.respondsToSelector(#selector(self.growingTextViewShouldEndEditing)) {
        return delegate!.growingTextViewShouldEndEditing(self)
    }
    else {
        return true
    }
}

func textView() {
    if delegate!.respondsToSelector(#selector(self.growingTextViewDidBeginEditing)) {
        delegate!.growingTextViewDidBeginEditing(self)
    }
}

func textView() {
    if delegate!.respondsToSelector(#selector(self.growingTextViewDidEndEditing)) {
        delegate!.growingTextViewDidEndEditing(self)
    }
}

func atext() {
    //weird 1 pixel bug when clicking backspace when textView is empty
    if !textView.hasText() && (atext == "") {
        return false
    }
    //Added by bretdabaker: sometimes we want to handle this ourselves
    if delegate!.respondsToSelector(Selector("growingTextView:shouldChangeTextInRange:replacementText:")) {
        return delegate!.growingTextView(self, shouldChangeTextInRange: range, replacementText: atext)
    }
    if (atext == "\n") {
        if delegate!.respondsToSelector(#selector(self.growingTextViewShouldReturn)) {
            if !delegate!.performSelector(#selector(self.growingTextViewShouldReturn), withObject: self) {
                return true
            }
            else {
                textView.resignFirstResponder()
                return false
            }
        }
    }
    return true
}

func textView() {
    if delegate!.respondsToSelector(#selector(self.growingTextViewDidChangeSelection)) {
        delegate!.growingTextViewDidChangeSelection(self)
    }
}