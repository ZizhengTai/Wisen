//
//  PaymentViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    var request: Request {
        return UserManager.sharedManager().user.currentRequest
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        PaymentManager.sharedManager().authenticateWithBlock { (Bool) -> Void in
            self.loadMentorInformation()
        }
    }

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel! {
        didSet {
            amountLabel?.text = "Amount:$\(request.requestFare())"
        }
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
        label.font = UIFont(name: "GillSans", size: 24)
        label.textColor = UIColor.whiteColor()
        navigationItem.titleView = label
    }
    @IBAction func payTouched(sender: UIButton) {
        PaymentManager.sharedManager().sendMoneywithAmountInUSD(request.requestFare(), block: { (Bool) -> Void in
            let alert = AMSmoothAlertView(dropAlertWithTitle: "Congrad!", andText: "You just paid your session!", andCancelButton: false, forAlertType: .Success)
            alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
                if button == alertObj.defaultButton {
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
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
}

