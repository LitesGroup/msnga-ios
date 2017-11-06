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

final class ChatViewController: JSQMessagesViewController
{
 var chatRef: DatabaseReference = Database.database().reference().child("channels")
 private lazy var messageRef: DatabaseReference = self.chatRef.child("messages")
 private var messageRefHandle: DatabaseHandle?

 var messages = [JSQMessage]()
 lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
 lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
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
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
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
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let item = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
        ]
        item.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    private func observeMessages() {
        let messageRef = chatRef.child("messages")
        let msgqry = messageRef.queryLimited(toLast: 25)
        messageRefHandle = msgqry.observe(.childAdded, with: {(snapshot) -> Void in
            let msgdata = snapshot.value as! Dictionary<String,String>
            if let id = msgdata["senderId"] as String!, let name = msgdata["senderName"] as String!, let text = msgdata["text"] as String!, text.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                self.finishReceivingMessage()
            }
            else{
                print("error getting messages")
            }
        })
    }
    
}
