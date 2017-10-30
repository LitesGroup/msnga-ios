//
//  ChatListController.swift
//  msnga
//
//  Created by Agrim Asthana on 10/26/17.
//  Copyright © 2017 LitesGroup. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ChatListController: UITableViewController {
    
var senderName: String?
var newChatTextField: UITextField?
private var channels: [Channel] = []
private var chatRef: DatabaseReference = Database.database().reference().child("channels")
private var chatRefHandle: DatabaseHandle?

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        channels.removeAll()
        observeChats()
        self.tableView.reloadData()
    }
    
    deinit {
        if let refHandle = chatRefHandle {
            chatRef.removeObserver(withHandle: refHandle)
        }
    }
    
    @IBAction func createChannel(_ sender: AnyObject){
        if let name = newChatTextField?.text {
            let newChatRef = chatRef.childByAutoId()
            let channelItem = [
                "name": name
            ]
            newChatRef.setValue(channelItem)
        }
        newChatTextField?.text = ""
    }
    
    public func observeChats(){
        chatRefHandle = chatRef.observe(.childAdded, with: { (snapshot) -> Void in
            let chatData = snapshot.value as! Dictionary<String,AnyObject>
            let id = snapshot.key
            if let name = chatData["name"] as! String!, name.count > 0 {
                self.channels.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("ERROR!")
            }
        })
    }
    
enum Section: Int {
    case createNewChatSection = 0
    case currentChatSection
}

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChatSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ChannelSelected", sender: channel)
        }
    }
    
    
}
