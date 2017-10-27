//
//  LoginViewController.swift
//  msnga
//
//  Created by Agrim Asthana on 10/25/17.
//  Copyright © 2017 LitesGroup. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if nameField?.text != "" {
            Auth.auth().signInAnonymously() { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                self.performSegue(withIdentifier: "LoginCompleted", sender: nil)
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        bottomConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomConstraint.constant = 48
    }


}
