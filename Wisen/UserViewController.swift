//
//  UserViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

//private let ColorSpectrum = [UIColor.redColor(), UIColor.orangeColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.blackColor()]

class UserViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            UserManager.sharedManager().user.getAllTagsWithBlock({ (tags: [AnyObject]!) -> Void in
                for tag in tags {
                    self.textView.text = "\(self.textView.text) #\(tag)"
                }
                self.formatTextinTextView(self.textView)
            })
        }
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (NSString(string: textView.text).hasSuffix(" ") || NSString(string: textView.text).length == 0) && (text != "#" && text != " ") {
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        formatTextinTextView(textView)
    }
    
    func formatTextinTextView(textView: UITextView) {
        let text = textView.text
        let selectedRange = textView.selectedRange
        let atrString = NSMutableAttributedString(string: text)
        atrString.addAttribute(NSFontAttributeName, value: UIFont(name: "GillSans", size: 23)!, range: NSMakeRange(0, NSString(string: text).length ))

        textView.scrollEnabled = false
        let regex = NSRegularExpression(pattern: "#(\\w+)", options:.CaseInsensitive , error: nil)
        let matches = regex?.matchesInString(text, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, NSString(string: text).length ))
        var matchTags = [String]()
        if let matches = matches as? [NSTextCheckingResult] {
            for match in matches {
                let matchRange = match.rangeAtIndex(0)
                matchTags += [NSString(string: text).substringWithRange(NSMakeRange(matchRange.location + 1, matchRange.length - 1) )]
                atrString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.blueColor(), range: matchRange)
                atrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: matchRange)
            }
        }
        textView.scrollEnabled = true
        textView.attributedText = atrString
        textView.selectedRange = selectedRange
        if (NSString(string: textView.text).hasSuffix(" ")) {
            UserManager.sharedManager().user.setTags(matchTags, withBlock: { (finished: Bool) -> Void in
                NSLog("Matches: \(matchTags)")
            })
        }
    }
}
