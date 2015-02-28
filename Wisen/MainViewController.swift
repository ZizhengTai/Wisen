//
//  MainViewController.swift
//  
//
//  Created by Yihe Li on 2/27/15.
//
//

import UIKit

private let DefaultDuration: NSTimeInterval = 0.3
private let SmallAvatarWidth: CGFloat = 30
class MainViewController: UIViewController {

    let user = UserManager.sharedManager().user
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var searchLabel: UILabel! {
        didSet {
            searchLabel.userInteractionEnabled = true
            searchLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "segueToSearch"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wisen"
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SmallAvatarWidth, height: SmallAvatarWidth))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = SmallAvatarWidth/2
        imageView.fetchImage(user.profileImageUrl)
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showProfile"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        // Do any additional setup after loading the view.
    }
    
    func showProfile() {
        topConstraint.constant = CGRectGetHeight(backgroundView.frame)
        UIView.animateWithDuration(DefaultDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func segueToSearch() {
        self.performSegueWithIdentifier("segueToSearch", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
}
