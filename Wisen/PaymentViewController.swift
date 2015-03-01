//
//  PaymentViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController, UITextFieldDelegate {
    
    lazy var pipe: MessagePipe = {
        var p = MessagePipe(selfUID: UserManager.sharedManager().user.uid, otherUID: self.recipientUID)
        return p
    }()
    
    var request: Request {
        return UserManager.sharedManager().user.currentRequest
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        if !isRecipient {
            self.payButton.hidden = true
            pipe.observeWithBlock({ (dic: [NSObject : AnyObject]!) -> Void in
                if let raw: AnyObject = dic["recipientEmail"] {
                    if let email = raw as? String {
                        PaymentManager.sharedManager().recipientAddress = email
                        self.payButton.hidden = false
                        let alert = AMSmoothAlertView(dropAlertWithTitle: "Hey!", andText: "He just put in his address, pay him now", andCancelButton: false, forAlertType: .Info)
                        
                        alert.show()
                    }
                }
            })
        } else {
            pipe.observeWithBlock({ (dic: [NSObject : AnyObject]!) -> Void in
                if let raw: AnyObject = dic["moneyRecieved"] {
                    if let result = raw as? NSNumber {
                        if result.boolValue {
                            let alert = AMSmoothAlertView(dropAlertWithTitle: "Hey!", andText: "You just got paid!", andCancelButton: false, forAlertType: .Success)
                            alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
                                if button == alertObj.defaultButton {
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                                }
                            }
                            alert.show()
                        }
                    }
                }
            })
        }
    }
    @IBOutlet weak var payButton: UIButton!

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.frame) / 2
            avatarImageView.layer.borderWidth = 4
            avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    @IBOutlet weak var amountLabel: UILabel! {
        didSet {
            amountLabel.text = "Amount:$\(request.requestFare())"
        }
    }
    @IBOutlet weak var recipientView: UIView! {
        didSet {
            recipientView.hidden = !isRecipient
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    @IBAction func emailConfirmed(sender: UIButton) {
        NSLog("Email confirmed")
        pipe.send(["recipientEmail": emailTextField.text])
    }
    @IBOutlet weak var recipientName: UILabel!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        label.text = "Check Out!"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "Futura-Medium", size: 24)
        label.textColor = UIColor.whiteColor()
        navigationItem.titleView = label
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isRecipient {
            PaymentManager.sharedManager().authenticateWithBlock { (Bool) -> Void in
                self.loadMentorInformation()
            }
        }
    }
    @IBAction func payTouched(sender: UIButton) {
        PaymentManager.sharedManager().sendMoneywithAmountInUSD(request.requestFare(), block: { (succeeded: Bool) -> Void in
            if succeeded {
                self.pipe.send(["moneyRecieved": NSNumber(bool: true)])
                let alert = AMSmoothAlertView(dropAlertWithTitle: "Congrad!", andText: "You just paid your session!", andCancelButton: false, forAlertType: .Success)
                alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
                    if button == alertObj.defaultButton {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }
                alert.show()
            } else {
                NSLog("Error")
            }
        })
    }
    
    func loadMentorInformation() {
        UserManager.sharedManager().getBasicInfoForUserWithUID(request.mentorUID, block: { (userInfo: [NSObject : AnyObject]?) -> Void in
            if let name: AnyObject? = userInfo?["displayName"] {
                if let displayName = name as? String {
                    self.recipientName.text = displayName
                }
            }
            if let avatar: AnyObject? = userInfo!["profileImageURL"] {
                if let avatarURL = avatar as? String {
                    self.avatarImageView.fetchImage(avatarURL)
                }
            }
        })
    }
    
    var isRecipient: Bool {
        return UserManager.sharedManager().user.uid == request.mentorUID
    }
    var recipientUID: String {
        return isRecipient ? request.menteeUID :request.mentorUID
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
}

