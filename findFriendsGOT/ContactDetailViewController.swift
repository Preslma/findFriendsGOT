//
//  ContactDetailViewController.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    var contact: Contact? {
        didSet {
            navigationItem.title = contact?.name
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.image = contact?.photo
        }
    }
    
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            bioTextView.text = contact?.description
        }
    }
}
