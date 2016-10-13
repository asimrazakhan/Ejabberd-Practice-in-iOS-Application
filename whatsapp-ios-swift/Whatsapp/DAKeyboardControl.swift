//
//  DAKeyboardControl.h
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 7/14/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//
import UIKit
typealias DAKeyboardDidMoveBlock = (keyboardFrameInView: CGRect, opening: Bool, closing: Bool) -> Void
/** DAKeyboardControl allows you to easily add keyboard awareness and scrolling
 dismissal (a receding keyboard ala iMessages app) to any UIView, UIScrollView
 or UITableView with only 1 line of code. DAKeyboardControl automatically
 extends UIView and provides a block callback with the keyboard's current origin.
 */
extension UIView {
    /** The keyboardTriggerOffset property allows you to choose at what point the
     user's finger "engages" the keyboard.
     */
    var keyboardTriggerOffset: CGFloat = 0.0
    private(set) var keyboardWillRecede = false
    /** Adding pan-to-dismiss (functionality introduced in iMessages)
     @param didMoveBlock called everytime the keyboard is moved so you can update
     the frames of your views
     @see addKeyboardNonpanningWithActionHandler:
     @see removeKeyboardControl
     */

    func addKeyboardPanningWithActionHandler(actionHandler: DAKeyboardDidMoveBlock) {
        self.addKeyboardControl(true, frameBasedActionHandler: actionHandler, constraintBasedActionHandler: 0)
    }

    func addKeyboardPanningWithFrameBasedActionHandler(didMoveFrameBasesBlock: DAKeyboardDidMoveBlock, constraintBasedActionHandler didMoveConstraintBasesBlock: DAKeyboardDidMoveBlock) {
        self.addKeyboardControl(true, frameBasedActionHandler: didMoveFrameBasesBlock, constraintBasedActionHandler: didMoveConstraintBasesBlock)
    }
    /** Adding keyboard awareness (appearance and disappearance only)
     @param didMoveBlock called everytime the keyboard is moved so you can update
     the frames of your views
     @see addKeyboardPanningWithActionHandler:
     @see removeKeyboardControl
     */

    func addKeyboardNonpanningWithActionHandler(actionHandler: DAKeyboardDidMoveBlock) {
        self.addKeyboardControl(false, frameBasedActionHandler: actionHandler, constraintBasedActionHandler: 0)
    }

    func addKeyboardNonpanningWithFrameBasedActionHandler(didMoveFrameBasesBlock: DAKeyboardDidMoveBlock, constraintBasedActionHandler didMoveConstraintBasesBlock: DAKeyboardDidMoveBlock) {
        self.addKeyboardControl(false, frameBasedActionHandler: didMoveFrameBasesBlock, constraintBasedActionHandler: didMoveConstraintBasesBlock)
    }
    /** Remove the keyboard action handler
     @note You MUST call this method to remove the keyboard handler before the view
     goes out of memory.
     */

    func removeKeyboardControl() {
        // Unregister for text input notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidBeginEditingNotification, object: nil)
        // Unregister for keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        // For the sake of 4.X compatibility
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardWillChangeFrameNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UIKeyboardDidChangeFrameNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        // Unregister any gesture recognizer
        self.removeGestureRecognizer(self.keyboardPanRecognizer)
        // Release a few properties
        self.frameBasedKeyboardDidMoveBlock = nil
        self.keyboardActiveInput = nil
        self.keyboardActiveView = nil
        self.keyboardPanRecognizer = nil
    }
    /** Returns the keyboard frame in the view */

    func keyboardFrameInView() -> CGRect {
        if self.keyboardActiveView {
            var keyboardFrameInView = self.convertRect(self.keyboardActiveView.frame, fromView: self.keyboardActiveView.superview!)
            return keyboardFrameInView
        }
        else {
            var keyboardFrameInView = CGRectMake(0.0, UIScreen.mainScreen().bounds.size.height, 0.0, 0.0)
            return keyboardFrameInView
        }
    }
    private(set) var keyboardOpened = false
    /** Convenience method to dismiss the keyboard */

    func hideKeyboard() {
        if self.keyboardActiveView {
            self.keyboardActiveView.hidden = true
            self.keyboardActiveView.userInteractionEnabled = false
            self.keyboardActiveInput.resignFirstResponder()
        }
    }


    class func load() {
            // Swizzle the 'addSubview:' method to ensure that all input fields
            // have a valid inputAccessoryView upon addition to the view heirarchy
        var originalSelector = #selector(self.addSubview)
        var swizzledSelector = #selector(self.swizzled_addSubview)
        var originalMethod = class_getInstanceMethod(self, originalSelector)
        var swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        class_addMethod(self, originalSelector, class_getMethodImplementation(self, originalSelector), method_getTypeEncoding(originalMethod))
        class_addMethod(self, swizzledSelector, class_getMethodImplementation(self, swizzledSelector), method_getTypeEncoding(swizzledMethod))
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
// MARK: - Public Methods

    func addKeyboardControl(panning: Bool, frameBasedActionHandler: DAKeyboardDidMoveBlock, constraintBasedActionHandler: DAKeyboardDidMoveBlock) {
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0)
        if panning && self.respondsToSelector(#selector(self.setKeyboardDismissMode)) {
            (self as! UIScrollView).keyboardDismissMode = .Interactive
        }
        else {
            self.panning = panning
        }
#else
        self.panning = panning
#endif
        self.frameBasedKeyboardDidMoveBlock = frameBasedActionHandler
        self.constraintBasedKeyboardDidMoveBlock = constraintBasedActionHandler
        // Register for text input notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.responderDidBecomeActive), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.responderDidBecomeActive), name: UITextViewTextDidBeginEditingNotification, object: nil)
        // Register for keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        // For the sake of 4.X compatibility
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardWillChangeFrame), name: "UIKeyboardWillChangeFrameNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardDidChangeFrame), name: "UIKeyboardDidChangeFrameNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.inputKeyboardDidHide), name: UIKeyboardDidHideNotification, object: nil)
    }
// MARK: - Input Notifications

    func responderDidBecomeActive(notification: NSNotification) {
        // Grab the active input, it will be used to find the keyboard view later on
        self.keyboardActiveInput = notification.object!
        if !self.keyboardActiveInput.inputAccessoryView! {
            var textField = (self.keyboardActiveInput as! UITextField)
            if textField.respondsToSelector(#selector(self.setInputAccessoryView)) {
                var nullView = UIView(frame: CGRectZero)
                nullView.backgroundColor! = UIColor.clearColor()
                textField.inputAccessoryView! = nullView
            }
            self.keyboardActiveInput = (textField as! UIResponder)
            // Force the keyboard active view reset
            self.inputKeyboardDidShow()
        }
    }
// MARK: - Keyboard Notifications

    func inputKeyboardWillShow(notification: NSNotification) {
        var keyboardEndFrameWindow: CGRect
        (notification.userInfo!.valueForKey(UIKeyboardFrameEndUserInfoKey) as! String).getValue(keyboardEndFrameWindow)
        var keyboardTransitionDuration: Double
        (notification.userInfo!.valueForKey(UIKeyboardAnimationDurationUserInfoKey) as! String).getValue(keyboardTransitionDuration)
        var keyboardTransitionAnimationCurve: UIViewAnimationCurve
        (notification.userInfo!.valueForKey(UIKeyboardAnimationCurveUserInfoKey) as! String).getValue(keyboardTransitionAnimationCurve)
        self.keyboardActiveView.hidden = false
        self.keyboardOpened = true
        var keyboardEndFrameView = self.convertRect(keyboardEndFrameWindow, fromView: nil)
        var constraintBasedKeyboardDidMoveBlockCalled = self.constraintBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView)
        if constraintBasedKeyboardDidMoveBlockCalled {
            self.constraintBasedKeyboardDidMoveBlock(keyboardEndFrameView, true, false)
        }
        UIView.animateWithDuration(keyboardTransitionDuration, delay: 0.0, options: AnimationOptionsForCurve(keyboardTransitionAnimationCurve) | .BeginFromCurrentState, animations: {() -> Void in
            if constraintBasedKeyboardDidMoveBlockCalled {
                self.layoutIfNeeded()
            }
            if self.frameBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView) {
                self.frameBasedKeyboardDidMoveBlock(keyboardEndFrameView, true, false)
            }
        }, completion: {(finished: __unused BOOL) -> Void in
            if self.panning && !self.keyboardPanRecognizer {
                // Register for gesture recognizer calls
                self.keyboardPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDidChange))
                self.keyboardPanRecognizer.minimumNumberOfTouches = 1
                self.keyboardPanRecognizer.delegate = self
                self.keyboardPanRecognizer.cancelsTouchesInView = false
                self.addGestureRecognizer(self.keyboardPanRecognizer)
            }
        })
    }

    func inputKeyboardDidShow() {
        // Grab the keyboard view
        self.keyboardActiveView = self.keyboardActiveInput.inputAccessoryView!.superview!
        self.keyboardActiveView.hidden = false
        // If the active keyboard view could not be found (UITextViews...), try again
        if !self.keyboardActiveView {
            // Find the first responder on subviews and look re-assign first responder to it
            self.keyboardActiveInput = self.recursiveFindFirstResponder(self)
            self.keyboardActiveView = self.keyboardActiveInput.inputAccessoryView!.superview!
            self.keyboardActiveView.hidden = false
        }
    }

    func inputKeyboardWillChangeFrame(notification: NSNotification) {
        var keyboardEndFrameWindow: CGRect
        (notification.userInfo!.valueForKey(UIKeyboardFrameEndUserInfoKey) as! String).getValue(keyboardEndFrameWindow)
        var keyboardTransitionDuration: Double
        (notification.userInfo!.valueForKey(UIKeyboardAnimationDurationUserInfoKey) as! String).getValue(keyboardTransitionDuration)
        var keyboardTransitionAnimationCurve: UIViewAnimationCurve
        (notification.userInfo!.valueForKey(UIKeyboardAnimationCurveUserInfoKey) as! String).getValue(keyboardTransitionAnimationCurve)
        var keyboardEndFrameView = self.convertRect(keyboardEndFrameWindow, fromView: nil)
        var constraintBasedKeyboardDidMoveBlockCalled = self.constraintBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView)
        if constraintBasedKeyboardDidMoveBlockCalled {
            self.constraintBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, false)
        }
        UIView.animateWithDuration(keyboardTransitionDuration, delay: 0.0, options: AnimationOptionsForCurve(keyboardTransitionAnimationCurve) | .BeginFromCurrentState, animations: {() -> Void in
            if constraintBasedKeyboardDidMoveBlockCalled {
                self.layoutIfNeeded()
            }
            if self.frameBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView) {
                self.frameBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, false)
            }
        }, completion: { _ in })
    }

    func inputKeyboardDidChangeFrame() {
        // Nothing to see here
    }

    func inputKeyboardWillHide(notification: NSNotification) {
        var keyboardEndFrameWindow: CGRect
        (notification.userInfo!.valueForKey(UIKeyboardFrameEndUserInfoKey) as! String).getValue(keyboardEndFrameWindow)
        var keyboardTransitionDuration: Double
        (notification.userInfo!.valueForKey(UIKeyboardAnimationDurationUserInfoKey) as! String).getValue(keyboardTransitionDuration)
        var keyboardTransitionAnimationCurve: UIViewAnimationCurve
        (notification.userInfo!.valueForKey(UIKeyboardAnimationCurveUserInfoKey) as! String).getValue(keyboardTransitionAnimationCurve)
        var keyboardEndFrameView = self.convertRect(keyboardEndFrameWindow, fromView: nil)
        var constraintBasedKeyboardDidMoveBlockCalled = self.constraintBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView)
        if constraintBasedKeyboardDidMoveBlockCalled {
            self.constraintBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, true)
        }
        UIView.animateWithDuration(keyboardTransitionDuration, delay: 0.0, options: AnimationOptionsForCurve(keyboardTransitionAnimationCurve) | .BeginFromCurrentState, animations: {() -> Void in
            if constraintBasedKeyboardDidMoveBlockCalled {
                self.layoutIfNeeded()
            }
            if self.frameBasedKeyboardDidMoveBlock && !CGRectIsNull(keyboardEndFrameView) {
                self.frameBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, true)
            }
        }, completion: {(finished: __unused BOOL) -> Void in
            // Remove gesture recognizer when keyboard is not showing
            self.removeGestureRecognizer(self.keyboardPanRecognizer)
            self.keyboardPanRecognizer = nil
        })
    }

    func inputKeyboardDidHide() {
        self.keyboardActiveView.hidden = false
        self.keyboardActiveView.userInteractionEnabled = true
        self.keyboardActiveView = nil
        self.keyboardActiveInput = nil
        self.keyboardOpened = false
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: __unused NSDictionary, context: __unused void) {
        if (keyPath == "frame") && object == self.keyboardActiveView {
            var keyboardEndFrameWindow = object.valueForKeyPath(keyPath)!.CGRectValue()
            var keyboardEndFrameView = self.convertRect(keyboardEndFrameWindow, fromView: self.keyboardActiveView.superview!)
            if CGRectEqualToRect(keyboardEndFrameView, self.previousKeyboardRect) {
                return
            }
            if !self.keyboardActiveView.hidden && !CGRectIsNull(keyboardEndFrameView) {
                if self.frameBasedKeyboardDidMoveBlock {
                    self.frameBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, false)
                }
                if self.constraintBasedKeyboardDidMoveBlock {
                    self.constraintBasedKeyboardDidMoveBlock(keyboardEndFrameView, false, false)
                    self.layoutIfNeeded()
                }
            }
            self.previousKeyboardRect = keyboardEndFrameView
        }
    }
// MARK: - Touches Management

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.keyboardPanRecognizer || otherGestureRecognizer == self.keyboardPanRecognizer {
            return true
        }
        else {
            return false
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer == self.keyboardPanRecognizer {
            // Don't allow panning if inside the active input (unless SELF is a UITextView and the receiving view)
            return (!touch.view.isFirstResponder() || (self is UITextView) && self.isEqual(touch.view))
        }
        else {
            return true
        }
    }

    func panGestureDidChange(gesture: UIPanGestureRecognizer) {
        if !self.keyboardActiveView || !self.keyboardActiveInput || self.keyboardActiveView.hidden {
            self.keyboardActiveInput = self.recursiveFindFirstResponder(self)
            self.keyboardActiveView = self.keyboardActiveInput.inputAccessoryView!.superview!
            self.keyboardActiveView.hidden = false
        }
        else {
            self.keyboardActiveView.hidden = false
        }
        var keyboardViewHeight: CGFloat = self.keyboardActiveView.bounds.size.height
        var keyboardWindowHeight: CGFloat = self.keyboardActiveView.superview!.bounds.size.height
        var touchLocationInKeyboardWindow = gesture.locationInView(self.keyboardActiveView.superview!)
        // If touch is inside trigger offset, then disable keyboard input
        if touchLocationInKeyboardWindow.y > keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset {
            self.keyboardActiveView.userInteractionEnabled = false
        }
        else {
            self.keyboardActiveView.userInteractionEnabled = true
        }
        switch gesture.state {
            case .Began:
                                // For the duration of this gesture, do not recognize more touches than
                // it started with
                gesture.maximumNumberOfTouches = gesture.numberOfTouches()

            case .Changed:
                                var newKeyboardViewFrame = self.keyboardActiveView.frame
                newKeyboardViewFrame.origin.y = touchLocationInKeyboardWindow.y + self.keyboardTriggerOffset
                // Bound the keyboard to the bottom of the screen
                newKeyboardViewFrame.origin.y = min(newKeyboardViewFrame.origin.y, keyboardWindowHeight)
                newKeyboardViewFrame.origin.y = max(newKeyboardViewFrame.origin.y, keyboardWindowHeight - keyboardViewHeight)
                // Only update if the frame has actually changed
                if newKeyboardViewFrame.origin.y != self.keyboardActiveView.frame.origin.y {
                    UIView.animateWithDuration(0.0, delay: 0.0, options: [.TransitionNone, .BeginFromCurrentState], animations: {() -> Void in
                        self.keyboardActiveView.frame = newKeyboardViewFrame
                        /* Unnecessary now, due to KVO on self.keyboardActiveView
                                                              CGRect newKeyboardViewFrameInView = [self convertRect:newKeyboardViewFrame
                                                              fromView:self.keyboardActiveView.window];
                                                              if (self.frameBasedKeyboardDidMoveBlock)
                                                              self.frameBasedKeyboardDidMoveBlock(newKeyboardViewFrameInView);
                                                              */
                    }, completion: { _ in })
                }

            case .Ended, .Cancelled:
                                var thresholdHeight: CGFloat = keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset + 44.0
                var velocity = gesture.velocityInView(self.keyboardActiveView)
                var shouldRecede: Bool
                if touchLocationInKeyboardWindow.y < thresholdHeight || velocity.y < 0 {
                    shouldRecede = false
                }
                else {
                    shouldRecede = true
                }
                    // If the keyboard has only been pushed down 44 pixels or has been
                    // panned upwards let it pop back up; otherwise, let it drop down
                var newKeyboardViewFrame = self.keyboardActiveView.frame
                newKeyboardViewFrame.origin.y = (!shouldRecede ? keyboardWindowHeight - keyboardViewHeight : keyboardWindowHeight)
                UIView.animateWithDuration(0.25, delay: 0.0, options: [.CurveEaseOut, .BeginFromCurrentState], animations: {() -> Void in
                    self.keyboardActiveView.frame = newKeyboardViewFrame
                    /* Unnecessary now, due to KVO on self.keyboardActiveView
                                                      CGRect newKeyboardViewFrameInView = [self convertRect:newKeyboardViewFrame
                                                      fromView:self.keyboardActiveView.window];
                                                      if (self.frameBasedKeyboardDidMoveBlock)
                                                      self.frameBasedKeyboardDidMoveBlock(newKeyboardViewFrameInView);
                                                      */
                }, completion: {(finished: __unused BOOL) -> Void in
                    self.keyboardActiveView().userInteractionEnabled = !shouldRecede
                    if shouldRecede {
                        self.hideKeyboard()
                    }
                })
                // Set the max number of touches back to the default
                gesture.maximumNumberOfTouches = NSUIntegerMax

            default:
                break
        }

    }
// MARK: - Internal Methods

    func recursiveFindFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder() {
            return view
        }
        var found: UIView? = nil
        for v: UIView in view.subviews {
            found = self.recursiveFindFirstResponder(v)
            if found != nil {

            }
        }
        return found
    }

    func swizzled_addSubview(subview: UIView) {
        if !subview.inputAccessoryView! {
            if (subview is UITextField) {
                var textField = (subview as! UITextField)
                if textField.respondsToSelector(#selector(self.setInputAccessoryView)) {
                    var nullView = UIView(frame: CGRectZero)
                    nullView.backgroundColor! = UIColor.clearColor()
                    textField.inputAccessoryView! = nullView
                }
            }
            else if (subview is UITextView) {
                var textView = (subview as! UITextView)
                if textView.respondsToSelector(#selector(self.setInputAccessoryView)) && textView.respondsToSelector(#selector(self.isEditable)) && textView.isEditable {
                    var nullView = UIView(frame: CGRectZero)
                    nullView.backgroundColor! = UIColor.clearColor()
                    textView.inputAccessoryView! = nullView
                }
            }
        }
        self.swizzled_addSubview(subview)
    }
// MARK: - Property Methods

    func previousKeyboardRect() -> CGRect {
        var previousRectValue = objc_getAssociatedObject(self, UIViewPreviousKeyboardRect)
        if previousRectValue {
            return previousRectValue.CGRectValue()
        }
        return CGRectZero
    }

    func setPreviousKeyboardRect(previousKeyboardRect: CGRect) {
        self.willChangeValueForKey("previousKeyboardRect")
        objc_setAssociatedObject(self, UIViewPreviousKeyboardRect, NSValue(CGRect: previousKeyboardRect), OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.didChangeValueForKey("previousKeyboardRect")
    }

    func frameBasedKeyboardDidMoveBlock() -> DAKeyboardDidMoveBlock {
        return objc_getAssociatedObject(self, UIViewKeyboardDidMoveFrameBasedBlock)
    }

    func setFrameBasedKeyboardDidMoveBlock(frameBasedKeyboardDidMoveBlock: DAKeyboardDidMoveBlock) {
        self.willChangeValueForKey("frameBasedKeyboardDidMoveBlock")
        objc_setAssociatedObject(self, UIViewKeyboardDidMoveFrameBasedBlock, frameBasedKeyboardDidMoveBlock, OBJC_ASSOCIATION_COPY)
        self.didChangeValueForKey("frameBasedKeyboardDidMoveBlock")
    }

    func constraintBasedKeyboardDidMoveBlock() -> DAKeyboardDidMoveBlock {
        return objc_getAssociatedObject(self, UIViewKeyboardDidMoveConstraintBasedBlock)
    }

    func setConstraintBasedKeyboardDidMoveBlock(constraintBasedKeyboardDidMoveBlock: DAKeyboardDidMoveBlock) {
        self.willChangeValueForKey("constraintBasedKeyboardDidMoveBlock")
        objc_setAssociatedObject(self, UIViewKeyboardDidMoveConstraintBasedBlock, constraintBasedKeyboardDidMoveBlock, OBJC_ASSOCIATION_COPY)
        self.didChangeValueForKey("constraintBasedKeyboardDidMoveBlock")
    }

    func keyboardTriggerOffset() -> CGFloat {
        var keyboardTriggerOffsetNumber = objc_getAssociatedObject(self, UIViewKeyboardTriggerOffset)
        return CFloat(keyboardTriggerOffsetNumber)
    }

    func setKeyboardTriggerOffset(keyboardTriggerOffset: CGFloat) {
        self.willChangeValueForKey("keyboardTriggerOffset")
        objc_setAssociatedObject(self, UIViewKeyboardTriggerOffset, Int(keyboardTriggerOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.didChangeValueForKey("keyboardTriggerOffset")
    }

    func isPanning() -> Bool {
        var isPanningNumber = objc_getAssociatedObject(self, UIViewIsPanning)
        return CBool(isPanningNumber)
    }

    func setPanning(panning: Bool) {
        self.willChangeValueForKey("panning")
        objc_setAssociatedObject(self, UIViewIsPanning, (panning), OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.didChangeValueForKey("panning")
    }

    func keyboardActiveInput() -> UIResponder {
        return objc_getAssociatedObject(self, UIViewKeyboardActiveInput)
    }

    func setKeyboardActiveInput(keyboardActiveInput: UIResponder) {
        self.willChangeValueForKey("keyboardActiveInput")
        objc_setAssociatedObject(self, UIViewKeyboardActiveInput, keyboardActiveInput, OBJC_ASSOCIATION_RETAIN)
        self.didChangeValueForKey("keyboardActiveInput")
    }

    func keyboardActiveView() -> UIView? {
        return objc_getAssociatedObject(self, UIViewKeyboardActiveView)
    }

    func setKeyboardActiveView(keyboardActiveView: UIView) {
        self.willChangeValueForKey("keyboardActiveView")
        self.keyboardActiveView.removeObserver(self, forKeyPath: "frame")
        if keyboardActiveView {
            keyboardActiveView.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        }
        objc_setAssociatedObject(self, UIViewKeyboardActiveView, keyboardActiveView, OBJC_ASSOCIATION_RETAIN)
        self.didChangeValueForKey("keyboardActiveView")
    }

    func keyboardPanRecognizer() -> UIPanGestureRecognizer {
        return objc_getAssociatedObject(self, UIViewKeyboardPanRecognizer)
    }

    func setKeyboardPanRecognizer(keyboardPanRecognizer: UIPanGestureRecognizer) {
        self.willChangeValueForKey("keyboardPanRecognizer")
        objc_setAssociatedObject(self, UIViewKeyboardPanRecognizer, keyboardPanRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.didChangeValueForKey("keyboardPanRecognizer")
    }

    func isKeyboardOpened() -> Bool {
        return CBool(objc_getAssociatedObject(self, UIViewKeyboardOpened))
    }

    func setKeyboardOpened(keyboardOpened: Bool) {
        self.willChangeValueForKey("keyboardOpened")
        objc_setAssociatedObject(self, UIViewKeyboardOpened, (keyboardOpened), OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.didChangeValueForKey("keyboardOpened")
    }

    func keyboardWillRecede() -> Bool {
        var keyboardViewHeight: CGFloat = self.keyboardActiveView.bounds.size.height
        var keyboardWindowHeight: CGFloat = self.keyboardActiveView.superview!.bounds.size.height
        var touchLocationInKeyboardWindow = self.keyboardPanRecognizer.locationInView(self.keyboardActiveView.superview!)
        var thresholdHeight: CGFloat = keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset + 44.0
        var velocity = self.keyboardPanRecognizer.velocityInView(self.keyboardActiveView)
        return touchLocationInKeyboardWindow.y >= thresholdHeight && velocity.y >= 0
    }
}
//
//  DAKeyboardControl.m
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 7/14/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//
import ObjectiveC
func AnimationOptionsForCurve(curve: UIViewAnimationCurve) -> inline UIViewAnimationOptions {
    return curve << 16
}

var UIViewKeyboardTriggerOffset = CChar()

var UIViewKeyboardDidMoveFrameBasedBlock = CChar()

var UIViewKeyboardDidMoveConstraintBasedBlock = CChar()

var UIViewKeyboardActiveInput = CChar()

var UIViewKeyboardActiveView = CChar()

var UIViewKeyboardPanRecognizer = CChar()

var UIViewPreviousKeyboardRect = CChar()

var UIViewIsPanning = CChar()

var UIViewKeyboardOpened = CChar()

extension UIView, UIGestureRecognizerDelegate {
    var frameBasedKeyboardDidMoveBlock = DAKeyboardDidMoveBlock()
    var constraintBasedKeyboardDidMoveBlock = DAKeyboardDidMoveBlock()
    var keyboardActiveInput: UIResponder!
    var keyboardActiveView: UIView!
    var keyboardPanRecognizer: UIPanGestureRecognizer!
    var previousKeyboardRect = CGRect.zero
    var panning = false
    var keyboardOpened = false
}