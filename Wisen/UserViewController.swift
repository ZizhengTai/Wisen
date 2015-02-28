//
//  UserViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

private let ColorSpectrum = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.blackColor()]

class UserViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    var startIndex = 0
    
    // MARK: Life Cycle
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        formatTextinTextView(textView)
    }
    
    func formatTextinTextView(textView: UITextView) {
        let text = textView.text
        let selectedRange = textView.selectedRange
        let atrString = NSMutableAttributedString(string: text)
        atrString.addAttribute(NSFontAttributeName, value: UIFont(name: "GillSans", size: 23)!, range: NSMakeRange(startIndex, NSString(string: text).length - startIndex))
        
        if (NSString(string: textView.text).hasSuffix(" ")) {
            textView.scrollEnabled = false
            let regex = NSRegularExpression(pattern: "#(\\w+)", options:.CaseInsensitive , error: nil)
            let matches = regex?.matchesInString(text, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(startIndex, NSString(string: text).length - startIndex))
            var matchTags = [String]()
            if let matches = matches as? [NSTextCheckingResult] {
                for match in matches {
                    let matchRange = match.rangeAtIndex(0)
                    matchTags += [NSString(string: text).substringWithRange(matchRange)]
                    let randomIndex = arc4random_uniform(UInt32(ColorSpectrum.count))
                    atrString.addAttribute(NSBackgroundColorAttributeName, value: ColorSpectrum[Int(randomIndex)], range: matchRange)
                    atrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(startIndex, NSString(string: text).length - startIndex))
                }
            }
            textView.scrollEnabled = true
            UserManager.sharedManager().user.setTags(matchTags, withBlock: { (finished: Bool) -> Void in
                NSLog("Matches: \(matchTags)")
            })
            startIndex = NSString(string: text).length
        }
        textView.attributedText = atrString
        textView.selectedRange = selectedRange
    }
}
