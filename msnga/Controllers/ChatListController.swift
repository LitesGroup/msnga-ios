//
//  ChatListController.swift
//  msnga
//
//  Created by Agrim Asthana on 10/26/17.
//  Copyright © 2017 LitesGroup. All rights reserved.
//

import Foundation
import Firebase

class ChatListController: UITableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        channels.append(Channel(id: "1", name: "Sports"))
        channels.append(Channel(id: "2", name: "Politics"))
        channels.append(Channel(id: "3", name: "Video Games"))
        self.tableView.reloadData()
    }
    
enum Section: Int {
    case createNewChatSection = 0
    case currentChatSection
}

var senderName: String?
var newChatTextField: UITextField?
private var channels: [Channel] = []

override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChatSection:
                return 1
            case .currentChatSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.currentChatSection.rawValue ? "ExistingChat" : "NewChat"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChatSection.rawValue {
            if let createNewChatCell = cell as? CreateChatCell {
                newChatTextField = createNewChatCell.newChatNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChatSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    
}
