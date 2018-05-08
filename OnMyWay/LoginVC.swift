//
//  LoginViewController.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
    
    private var initialBotConstraint:CGFloat!
    
    private lazy var userRef: DatabaseReference = Database.database().reference().child("users")
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Actions
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
    
        if let name = nameField?.text, name != "" {
            UserManager.shared.connect(name: name) { [weak self] (user) in
             //   <#code#>
            }
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let err:Error = error {
                    print(err.localizedDescription)
                    return
                }

                let itemRef = self.userRef.child(user!.uid)
                
                let userItem = [
                    "userName": self.nameField.text!,
                    "uniqueid": user!.uid
                    ]
                
                itemRef.setValue(userItem)
                
                self.presentMapVC()
                
            })
        }
    }
    
}

//************************************
// MARK: - Navigation
//************************************

extension LoginVC {
    
    func presentMapVC() {
        
        let mapVC = MapVC()
        self.present(mapVC, animated: true, completion: nil)
        
    }
    
}

//************************************
// MARK: - Keyboard Handling
//************************************

extension LoginVC {
    
    func setupKeyboard() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapGesture)

        initialBotConstraint = bottomLayoutGuideConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func tapView() {
        self.nameField.resignFirstResponder()
    }
    
    
    @objc func keyboardWillChange(notification:NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        //let frameStart = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animTime = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSValue) as? Double
        let curve = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        let convRect = self.view.convert(frameEnd, from: nil)
        var yOffset = self.view.bounds.size.height - convRect.origin.y
        
        let show = frameEnd.height > 100
        
        if #available(iOS 11.0, *) {
            let bottomInset = view.safeAreaInsets.bottom
            if show { yOffset -= bottomInset }
        }
        
        bottomLayoutGuideConstraint.constant = max(yOffset, 0) + initialBotConstraint
        
        UIView.animate(withDuration: animTime!, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (value: Bool) in
            
        })
        

        
        
    }
    
}




