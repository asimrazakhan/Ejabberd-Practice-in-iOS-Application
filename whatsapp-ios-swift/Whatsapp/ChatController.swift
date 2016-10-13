//
//  ChatListController.h
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//
import UIKit
//
// This class is a list of chat conversations
//
class ChatController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableView()
        self.setTest()
        self.title = "Chats"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    func setTableView() {
        self.tableData = [AnyObject]()
        self.tableView.delegate! = self
        self.tableView.dataSource! = self
        self.tableView.tableFooterView! = UIView(frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 10.0))
        self.tableView.backgroundColor = UIColor.clearColor()
    }

    func setTest() {
        var contact = Contact()
        contact.name = "Player 1"
        contact.identifier = "12345"
        var chat = Chat()
        chat.contact = contact
        var texts = ["Hello!", "This project try to implement a chat UI similar to Whatsapp app.", "Is it close enough?"]
        var last_message: Message? = nil
        for text: String in texts {
            var message = Message()
            message.text = text
            message.sender = MessageSenderSomeone
            message.status = MessageStatusReceived
            message.chat_id = chat.identifier
            LocalStorage.sharedInstance().storeMessage(message)
            last_message = message
        }
        chat.numberOfUnreadMessages = texts.count
        chat.last_message = last_message
        self.tableData.append(chat)
    }
// MARK: - TableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var CellIdentifier = "ChatListCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)!
        if !cell {
            cell = ChatCell(style: .Default, reuseIdentifier: CellIdentifier)
        }
        cell.chat = self.tableData[indexPath.row]
        return cell
    }
// MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var controller = self.storyboard!.instantiateViewControllerWithIdentifier("Message")
        controller.chat = self.tableData[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
    }

    @IBOutlet weak var tableView: UITableView!
    var tableData = [AnyObject]()
}
//
//  ChatListController.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//