//
//  ConfirmationViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    var clockFace: ClockFace?
    override func viewDidLoad() {
        super.viewDidLoad()
        clockFace = ClockFace()
        clockFace?.position = CGPoint(x:self.view.bounds.size.width , y: 150)
        self.view.layer.addSublayer(self.clockFace);
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        clockFace?.time = NSString(string:textField.text).floatValue;
    }
    
}
