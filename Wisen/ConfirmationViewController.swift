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
    var timer: NSTimer?
    var clockFace: ClockFace?
    var minutesLeft: Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        clockFace = ClockFace()
        clockFace?.position = CGPoint(x:self.view.bounds.size.width/2 , y: 150)
        self.view.layer.addSublayer(self.clockFace);
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        clockFace?.myTime = NSString(string:textField.text).floatValue;
        minutesLeft = floor(Double(clockFace!.myTime * 60))
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateClockFace", userInfo: nil, repeats: true)
    }
    
    func updateClockFace() {
        if var min = minutesLeft {
            min = Double(min - Double(1))
            if min <= Double(0) {
                min = 0
                requestFinished()
            }
            clockFace?.myTime = Float(min / Double(60))
        }
    }
    
    func requestFinished() {
        let alert = AMSmoothAlertView(dropAlertWithTitle: "Congrads!", andText: "You just finished your learning session", andCancelButton: false, forAlertType: .Success)
        alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
            if button == alertObj.defaultButton {
                self.dismissSelf()
            }
        }
        alert.show()
    }
    
    func dismissSelf() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
