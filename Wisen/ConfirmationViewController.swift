//
//  ConfirmationViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

private let Scale:CGFloat = 300;

class ConfirmationViewController: UIViewController, TimerDelegate {

    var request: Request {
        return UserManager.sharedManager().user.currentRequest
    }
    var timer:Timer?
    var clockFace: ClockFace?
    var minutesLeft: Double?
    var pan: UIPanGestureRecognizer?
    var disabled = false
    override func viewDidLoad() {
        super.viewDidLoad()
        clockFace = ClockFace()
        clockFace?.position = CGPointMake(self.view.bounds.width / 2, self.view.bounds.width / 2)
        self.view.layer.addSublayer(self.clockFace);
        pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.view.addGestureRecognizer(pan!)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }

    @IBAction func startTouched(sender: UIButton) {
        disabled = true
        request.durationInHours = NSTimeInterval(clockFace!.myTime)
        minutesLeft = floor(Double(clockFace!.myTime * 60))
        timer = Timer(duration: NSTimeInterval(clockFace!.myTime * 60.0 * 60.0), timeInterval: 1, completionNotification: nil, delegate: self)
        
        timer?.start()
        
//         TEST
//        requestFinished()
    }
    
    func timer(timer: Timer!, didFireWithRemainingTime remainingTime: NSTimeInterval) {
        NSLog("Timer: %f", remainingTime)
        updateClockFace(remainingTime)
    }
    
    func timer(timer: Timer!, didStopAtDate date: NSDate!) {
        clockFace?.myTime = 0
        requestFinished()
    }
    
    func updateClockFace(remaining: NSTimeInterval) {
        var remaining = remaining
        if remaining <= 0 {
            remaining = 0
            requestFinished()
        }
        clockFace?.myTime = Float(remaining / Double(3600))
    }
    
    func requestFinished() {
        timer?.abort()
        let alert = AMSmoothAlertView(dropAlertWithTitle: "Congrads!", andText: "You just finished your learning session", andCancelButton: false, forAlertType: .Success)
        alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
            if button == alertObj.defaultButton {
                self.segueToPayment()
            }
        }
        alert.show()
    }
    
    func segueToPayment() {
        navigationController?.pushViewController(storyboard?.instantiateViewControllerWithIdentifier("PaymentScene") as UIViewController, animated: true)
    }
    
    func handlePan(g: UIPanGestureRecognizer) {
        if !disabled {
            let point = g.translationInView(g.view!)
            NSLog("Y: %@", point.y)
            clockFace!.myTime = max(0, clockFace!.myTime + Float(point.y / Scale));
            g.setTranslation(CGPointZero, inView: g.view)
        }
    }
    
    deinit {
        timer?.abort()
    }
}
