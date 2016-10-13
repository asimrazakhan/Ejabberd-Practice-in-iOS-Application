//
//  Contact.h
//  Whatsapp
//
//  Created by Magneto on 2/12/16.
//  Copyright © 2016 HummingBird. All rights reserved.
//
import UIKit
import Foundation
class Contact: NSObject {
    var identifier = ""
    var name = ""
    var image_id = ""

    func hasImage() -> Bool {
        return !(self.image_id == "")
    }

    func save() {
        LocalStorage.storeContact(self)
    }

    class func contactFromDictionary(dict: [NSObject : AnyObject]) -> Contact {
        var contact = Contact()
        contact.name = dict["name"]
        contact.identifier = dict["id"]
        contact.image_id = dict["image_id"]
        return contact
    }

    class func queryForName(name: String) -> Contact {
    }
}
//
//  Contact.m
//  Whatsapp
//
//  Created by Magneto on 2/12/16.
//  Copyright © 2016 HummingBird. All rights reserved.
//