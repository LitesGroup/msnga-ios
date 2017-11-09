//
//  ChatViewController.swift
//  msnga
//
//  Created by Agrim Asthana on 10/29/17.
//  Copyright © 2017 LitesGroup. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import JSQMessagesViewController
import Alamofire
import SwiftyJSON

final class ChatViewController: JSQMessagesViewController
{
 var chatRef: DatabaseReference = Database.database().reference().child("channels")
 private lazy var messageRef: DatabaseReference = self.chatRef.child("messages")
 private var messageRefHandle: DatabaseHandle?

 var messages = [JSQMessage]()
 lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
 lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData? {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    
    var chat: Channel? {
        didSet {
            title = chat?.name
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
        self.senderId = Auth.auth().currentUser?.uid
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    private func addMessage(withId id: String, name: String, text: String, sent: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            message.accessibilityValue = sent;
            messages.append(message)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        if (message.accessibilityValue?.count != 0) {
            let sent = Float(message.accessibilityValue!)
            cell.messageBubbleImageView.image? = (cell.messageBubbleImageView.image?.withRenderingMode(.alwaysTemplate))!
            switch(sent!){
            case -1 ... -0.75:
                cell.messageBubbleImageView.tintColor = UIColor(red:(254/255.0), green: (16/255.0), blue: (0/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.white
            case -0.75 ... -0.50:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(251/255.0), green: (79/255.0), blue: (7/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.white
            case -0.50 ... -0.25:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(249/255.0), green: (138/255.0), blue: (13/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.white
            case -0.25...0.09:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(247/255.0), green: (194/255.0), blue: (19/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.black
            case 0.00...0.25:
                cell.messageBubbleImageView?.tintColor = UIColor(red: (244/255.0), green: (245/255.0), blue: (25/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.black
            case 0.25...0.50:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(192/255.0), green: (243/255.0), blue: (30/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.black
            case 0.50...0.75:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(143/255.0), green: (241/255.0), blue: (36/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.black
            case 0.75...1:
                cell.messageBubbleImageView?.tintColor = UIColor(red:(99/255.0), green: (239/255.0), blue: (42/255.0), alpha: 1.0)
                cell.textView?.textColor = UIColor.black
            default:
                cell.messageBubbleImageView?.tintColor = UIColor.blue
            }
        }
        
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let item = messageRef.childByAutoId()
        let params: Parameters = [
            "sentence": text
        ]
        Alamofire.request("http://127.0.0.1:8000/parse", method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyVar = JSON(responseData.result.value!)
                print(swiftyVar["compound"])
            
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "sentimentScore": swiftyVar["compound"].stringValue
            ] as [String: Any]
        item.setValue(messageItem)
        }
            else{
                let messageItem = [
                    "senderId": senderId!,
                    "senderName": senderDisplayName!,
                    "text": text!
                ]
                item.setValue(messageItem)
            }
        }
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    private func observeMessages() {
        let messageRef = chatRef.child("messages")
        let msgqry = messageRef.queryLimited(toLast: 25)
        messageRefHandle = msgqry.observe(.childAdded, with: {(snapshot) -> Void in
            let msgdata = snapshot.value as! Dictionary<String,String>
            if let id = msgdata["senderId"] as String!, let name = msgdata["senderName"] as String!, let text = msgdata["text"] as String!, let sent = msgdata["sentimentScore"] as String!, text.count > 0 {
                self.addMessage(withId: id, name: name, text: text, sent: sent )
                self.finishReceivingMessage()
            }
            else{
                print("error getting messages")
            }
        })
    }
    
}
