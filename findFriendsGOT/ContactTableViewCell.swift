//
//  ContactTableViewCell.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    var contact: Contact? {
        didSet {
            textLabel?.text = contact?.name
        }
    }
}
