//
//  ChatController.h
//  Whatsapp
//
//  Created by Rafael Castro on 6/16/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
//
// This class control chat exchange message itself
// It creates the bubble UI
//
class MessageController: UIViewController {
    var chat: Chat? {
        get {
            // TODO: add getter implementation
        }
        set(chat) {
            self.chat = chat
            self.title = chat.contact.name
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInputbar()
        self.setTableView()
        self.setGateway()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        weak var inputbar = inputbar
        weak var tableView = tableView
        weak var controller = self
        self.view.keyboardTriggerOffset = inputbar!.frame.size.height
        self.view.addKeyboardPanningWithActionHandler({(keyboardFrameInView: CGRect, opening: Bool, closing: Bool) -> Void in
                /*
                         Try not to call "self" inside this block (retain cycle).
                         But if you do, make sure to remove DAKeyboardControl
                         when you are done with the view controller by calling:
                         [self.view removeKeyboardControl];
                         */
            var toolBarFrame = inputbar!.frame
            toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height
            inputbar!.frame = toolBarFrame
            var tableViewFrame = tableView!.frame
            tableViewFrame.size.height = toolBarFrame.origin.y - 64
            tableView!.frame = tableViewFrame
            controller!.tableViewScrollToBottomAnimated(false)
        })
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        self.view.removeKeyboardControl()
        self.gateway.dismiss()
    }

    override func viewWillDisappear(animated: Bool) {
        self.chat.last_message = self.tableArray.last!
    }
// MARK: -

    func setInputbar() {
        self.inputbar.placeholder = nil
        self.inputbar.delegate = self
        self.inputbar.leftButtonImage = UIImage(named: "share")!
        self.inputbar.rightButtonText = "Send"
        self.inputbar.rightButtonTextColor = UIColor(red: 0, green: 124 / 255.0, blue: 1, alpha: 1)
    }

    func setTableView() {
        self.tableArray = TableArray()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView! = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 10.0))
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.registerClass(MessageCell.self, forCellReuseIdentifier: "MessageCell")
    }

    func setGateway() {
        self.gateway = MessageGateway.sharedInstance()
        self.gateway.delegate = self
        self.gateway.chat = self.chat
        self.gateway.loadOldMessages()
    }
// MARK: - Actions

    @IBAction func userDidTapScreen(sender: AnyObject) {
        inputbar!.resignFirstResponder()
    }
// MARK: - TableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableArray.numberOfSections()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableArray.numberOfMessagesInSection(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var CellIdentifier = "MessageCell"
        var cell = tableView!.dequeueReusableCellWithIdentifier(CellIdentifier)!
        if !cell {
            cell = MessageCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        cell.message = self.tableArray.objectAtIndexPath(indexPath)
        return cell
    }
// MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var message = self.tableArray.objectAtIndexPath(indexPath)
        return message.heigh
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.tableArray.titleForSection(section)
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var frame = CGRectMake(0, 0, tableView!.frame.size.width, 40)
        var view = UIView(frame: frame)
        view.backgroundColor! = UIColor.clearColor()
        view.autoresizingMask = .FlexibleWidth
        var label = UILabel()
        label.text! = self.tableView(tableView, titleForHeaderInSection: section)!
        label.textAlignment = .Center
        label.font = UIFont(name: "Helvetica", size: 20.0)
        label.sizeToFit()
        label.center = view.center
        label.font = UIFont(name: "Helvetica", size: 13.0)
        label.backgroundColor = UIColor(red: 207 / 255.0, green: 220 / 255.0, blue: 252.0 / 255.0, alpha: 1)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.autoresizingMask = .None
        view.addSubview(label)
        return view
    }

    func tableViewScrollToBottomAnimated(animated: Bool) {
        var numberOfSections = self.tableArray.numberOfSections()
        var numberOfRows = self.tableArray.numberOfMessagesInSection(numberOfSections - 1)
        if numberOfRows != 0 {
            tableView!.scrollToRowAtIndexPath(self.tableArray(), atScrollPosition: .Bottom, animated: animated)
        }
    }
// MARK: - InputbarDelegate

    func inputbarDidPressRightButton(inputbar: Inputbar) {
        var message = Message()
        message.text = inputbar!.text
        message.date! = NSDate()
        message.chat_id = chat!.identifier
        //Store Message in memory
        self.tableArray.append(message)
            //Insert Message in UI
        var indexPath = self.tableArray(forMessage: message)
        self.tableView.beginUpdates()
        if self.tableArray.numberOfMessagesInSection(indexPath.section) == 1 {
            self.tableView.insertSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation: .None)
        }
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
        self.tableView.endUpdates()
        self.tableView.scrollToRowAtIndexPath(self.tableArray(), atScrollPosition: .Bottom, animated: true)
        //Send message to server
        self.gateway.sendMessage(message)
    }

    func inputbarDidPressLeftButton(inputbar: Inputbar) {
        var alertView = UIAlertView(title: "Left Button Pressed", message: nil, delegate: nil, cancelButtonTitle: "Ok")
        alertView.show()
    }

    func inputbarDidChangeHeight(new_height: CGFloat) {
        //Update DAKeyboardControl
        self.view.keyboardTriggerOffset = new_height
    }
// MARK: - MessageGatewayDelegate

    func gatewayDidUpdateStatusForMessage(message: Message) {
        var indexPath = self.tableArray(forMessage: message)
        var cell = (self.tableView.cellForRowAtIndexPath(indexPath)! as! MessageCell)
        cell.updateMessageStatus()
    }

    func gatewayDidReceiveMessages(array: [AnyObject]) {
        self.tableArray += array
        self.tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputbar: Inputbar!
    var tableArray: TableArray!
    var gateway: MessageGateway!
}
//
//  MessageController.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/23/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//