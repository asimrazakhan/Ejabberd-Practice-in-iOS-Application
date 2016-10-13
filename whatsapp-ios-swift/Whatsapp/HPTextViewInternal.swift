//
//  HPTextViewInternal.h
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
class HPTextViewInternal: UITextView {
    var placeholder: String {
        get {
            // TODO: add getter implementation
        }
        set(placeholder) {
            self.placeholder = placeholder
            self.setNeedsDisplay()
        }
    }
    var placeholderColor: UIColor!
    var displayPlaceHolder = false


    override func setText(text: String) {
        var originalValue = self.scrollEnabled
        //If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled == NO,
        //setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled==yes
        //then scroll it erratically. Setting scrollEnabled temporarily to YES prevents this.
        self.scrollEnabled = true
        super.text = text
        self.scrollEnabled = originalValue
    }

    func setScrollable(isScrollable: Bool) {
        super.scrollEnabled = isScrollable
    }

    override func setContentOffset(s: CGPoint) {
        if self.tracking || self.decelerating {
                //initiated by user...
            var insets = self.contentInset
            insets.bottom = 0
            insets.top = 0
            self.contentInset = insets
        }
        else {
            var bottomOffset: Float = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom)
            if s.y! < bottomOffset && self.scrollEnabled {
                var insets = self.contentInset
                insets.bottom = 8
                insets.top = 0
                self.contentInset = insets
            }
        }
        // Fix "overscrolling" bug
        if s.y! > self.contentSize.height - self.frame.size.height && !self.decelerating && !self.tracking && !self.dragging {
            s = CGPointMake(s.x!, self.contentSize.height - self.frame.size.height)
        }
        super.contentOffset = s
    }

    override func setContentInset(s: UIEdgeInsets) {
        var insets = s
        if s.bottom > 8 {
            insets.bottom = 0
        }
        insets.top = 0
        super.contentInset = insets
    }

    override func setContentSize(contentSize: CGSize) {
        // is this an iOS5 bug? Need testing!
        if self.contentSize.height > contentSize.height {
            var insets = self.contentInset
            insets.bottom = 0
            insets.top = 0
            self.contentInset = insets
        }
        super.contentSize = contentSize
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if self.displayPlaceHolder && self.placeholder && self.placeholderColor {
            if self.respondsToSelector(#selector(self.snapshotViewAfterScreenUpdates)) {
                var paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = self.textAlignment
                self.placeholder.drawInRect(CGRectMake(5, 8 + self.contentInset.top, self.frame.size.width - self.contentInset.left, self.frame.size.height - self.contentInset.top), withAttributes: [NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.placeholderColor, NSParagraphStyleAttributeName: paragraphStyle])
            }
            else {
                Set<NSObject>()
                self.placeholder.drawInRect(CGRectMake(8.0, 8.0, self.frame.size.width - 16.0, self.frame.size.height - 16.0), withFont: self.font)
            }
        }
    }
}
//
//  HPTextViewInternal.m
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