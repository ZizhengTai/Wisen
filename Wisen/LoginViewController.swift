//
//  LoginViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginTouched(sender: UIButton) {
        UserManager.sharedManager().logInWithTwitterWithBlock { (let finished) -> Void in
            let delegate = UIApplication.sharedApplication().delegate as AppDelegate
            delegate.window.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScene") as? UIViewController
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
}
