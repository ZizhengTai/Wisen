//
//  ConfirmationViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController, UITextFieldDelegate, TimerDelegate {

    var request: Request {
        return UserManager.sharedManager().user.currentRequest
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    var timer:Timer?
    var clockFace: ClockFace?
    var minutesLeft: Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        clockFace = ClockFace()
        clockFace?.position = CGPoint(x:self.view.bounds.size.width/2 , y: 150)
        self.view.layer.addSublayer(self.clockFace);
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let duration = NSString(string:textField.text).floatValue;
        clockFace?.myTime = duration;
        request.durationInHour = NSTimeInterval(duration)
        minutesLeft = floor(Double(clockFace!.myTime * 60))
        timer = Timer(duration: NSTimeInterval(duration * 60.0), timeInterval: 1, completionNotification: nil, delegate: self)
        
        timer?.start()
        
        // TEST
        requestFinished()
    }
    
    func timer(timer: Timer!, didFireWithRemainingTime remainingTime: NSTimeInterval) {
        updateClockFace(remainingTime)
    }
    
    func updateClockFace(remaining: NSTimeInterval) {
        var remaining = remaining
        if remaining <= 0 {
            remaining = 0
            requestFinished()
        }
        clockFace?.myTime = Float(remaining / Double(60))
    }
    
    func requestFinished() {
        timer?.abort()
        let alert = AMSmoothAlertView(dropAlertWithTitle: "Congrads!", andText: "You just finished your learning session", andCancelButton: false, forAlertType: .Success)
        alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
            if button == alertObj.defaultButton {
//                self.dismissSelf()
                self.segueToPayment()
            }
        }
        alert.show()
    }
    
    func dismissSelf() {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func segueToPayment() {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("PaymentScene") as UIViewController, animated: true)
    }
    
    deinit {
        timer?.abort()
    }
}
