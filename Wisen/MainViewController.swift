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
    @IBOutlet weak var MainView: UIView! {
        didSet {
            MainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideProfile"))
        }
    }
    @IBOutlet weak var profileAvatar: UIImageView! {
        didSet {
            profileAvatar.clipsToBounds = true
            profileAvatar.layer.cornerRadius = CGRectGetWidth(profileAvatar.frame)/2
        profileAvatar .fetchImage(user.profileImageURL)
        }
    }
    @IBOutlet weak var searchLabel: UILabel! {
        didSet {
            searchLabel.userInteractionEnabled = true
            searchLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "segueToSearch"))
        }
    }
    var profileShown = false
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wisen"
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SmallAvatarWidth, height: SmallAvatarWidth))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = SmallAvatarWidth/2
        imageView.fetchImage(user.profileImageURL)
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showProfile"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    // MARK: Transition
    func showProfile() {
        profileShown = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        topConstraint.constant = CGRectGetHeight(backgroundView.frame)
        UIView.animateWithDuration(DefaultDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func hideProfile() {
        if (!profileShown) {
            return
        }
        navigationController?.setNavigationBarHidden(false, animated: true)
        topConstraint.constant = 0
        UIView.animateWithDuration(DefaultDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        profileShown = false
    }

    func segueToSearch() {
        self.performSegueWithIdentifier("segueToSearch", sender: nil)
    }

}
