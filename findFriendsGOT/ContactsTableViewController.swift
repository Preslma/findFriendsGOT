//
//  ContactsTableViewController.swift
//  findFriendsGOT
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    
    var contactList = [Contact]()
    var selectedContact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupContacts()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else {
            return UITableViewCell()
        }
        cell.contact = contactList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContact = contactList[indexPath.row]
        WatchConnectivityManager.sharedInstance.selectedContact = selectedContact
        performSegue(withIdentifier: "showDetailView", sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVc = segue.destination as? ContactDetailViewController else {
            return
        }
        destVc.contact = selectedContact
    }
    
    // MARK: - Data Setup
    
    func setupContacts() {
        contactList.append(Contact(name: KnownContactNames.WhiteWalker.rawValue, description: Constants.WhiteWalkerBio))
        contactList.append(Contact(name: KnownContactNames.Daenerys.rawValue, description: Constants.DaenerysBio))
        contactList.append(Contact(name: KnownContactNames.JonSnow.rawValue, description: Constants.JonSnowBio))
        contactList.append(Contact(name: KnownContactNames.Jaime.rawValue, description: Constants.JaimeLannisterBio))
        contactList.append(Contact(name: KnownContactNames.AryaStark.rawValue, description: Constants.AryaStarkBio))
        contactList.append(Contact(name: KnownContactNames.BranStark.rawValue, description: Constants.BranStarkBio))
    }
}
