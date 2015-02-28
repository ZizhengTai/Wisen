//
//  MainViewController.swift
//  
//
//  Created by Yihe Li on 2/27/15.
//
//

import UIKit

private let BackgroundCell = "BackgroundCell"
private let DefaultDuration: NSTimeInterval = 0.3
private let SmallAvatarWidth: CGFloat = 30
private let CellHeight: CGFloat = 60

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private struct CellText {
        static let FirstCell = "FIND YOUR MENTOR"
        static let SecondCell = "PAYMENT"
        static let ThirdCell = "PROMOTIONS"
        static let ForthCell = "FREE MENTOR"
        static let FifthCell = "SUPPORT"
        static let SixCell = "ABOUT"
    }
    
    private struct CellPhoto {
        static let FirstCell = "FIND YOUR MENTOR"
        static let SecondCell = "PAYMENT"
        static let ThirdCell = "PROMOTIONS"
        static let ForthCell = "FREE MENTOR"
        static let FifthCell = "SUPPORT"
        static let SixCell = "ABOUT"
    }
    
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
            profileAvatar.fetchImage(user.profileImageUrl)
            profileAvatar.userInteractionEnabled = true
            profileAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "segueToUser"))
        }
    }
    @IBOutlet weak var searchLabel: UILabel! {
        didSet {
            searchLabel.userInteractionEnabled = true
            searchLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "segueToSearch"))
        }
    }
    @IBOutlet weak var backgroundTableView: UITableView! {
        didSet {
            backgroundTableView.delegate = self
            backgroundTableView.dataSource = self
            backgroundTableView.registerNib(UINib(nibName: "BackgroundTableViewCell", bundle: nil), forCellReuseIdentifier: BackgroundCell)
            backgroundTableView.separatorStyle = .None
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
        performSegueWithIdentifier("segueToSearch", sender: nil)
    }
    
    func segueToUser() {
        navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("UserScene") as UIViewController, animated: true)
    }
    
    // MARK: UITableView Method
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BackgroundCell, forIndexPath: indexPath) as BackgroundTableViewCell
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = CellText.FirstCell
            cell.avtarImageView.fetchImage(CellPhoto.FirstCell)
        case 1:
            cell.titleLabel.text = CellText.SecondCell
            cell.avtarImageView.fetchImage(CellPhoto.SecondCell)
        case 2:
            cell.titleLabel.text = CellText.ThirdCell
            cell.avtarImageView.fetchImage(CellPhoto.ThirdCell)
        case 3:
            cell.titleLabel.text = CellText.ForthCell
            cell.avtarImageView.fetchImage(CellPhoto.ForthCell)
        case 4:
            cell.titleLabel.text = CellText.FifthCell
            cell.avtarImageView.fetchImage(CellPhoto.FifthCell)
        case 5:
            cell.titleLabel.text = CellText.SixCell
            cell.avtarImageView.fetchImage(CellPhoto.SixCell)
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CellHeight
    }
}
