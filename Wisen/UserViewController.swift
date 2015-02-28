//
//  UserViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        formatTextinTextView(textView)
        return true
    }
    
    func formatTextinTextView(textView: UITextView) {
        textView.scrollEnabled = false
        let selectedRange = textView.selectedRange
        let text = textView.text
        
        let atrString = NSMutableAttributedString(string: text)
        let regex = NSRegularExpression(pattern: "#(\\w+)", options:.CaseInsensitive , error: nil)
        let matches = regex?.matchesInString(text, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, NSString(string: text).length))
        if let matches = matches as? [NSTextCheckingResult] {
            for match in matches {
                let matchRange = match.rangeAtIndex(0)
                atrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: matchRange)
            }
        }
        textView.attributedText = atrString
        textView.selectedRange = selectedRange
        textView.scrollEnabled = true
    }
}
