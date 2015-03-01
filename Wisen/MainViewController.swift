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
private let MainCell = "MainCell"
private let ImageHeight: CGFloat = 200
private let ImageOffsetSpeed: CGFloat = 25

let kRequestConfirmedByMentorNotification = "kRequestConfirmedByMentorNotification"
let kRequestCanceledNotification = "kRequestCanceledNotification"

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var images = TrendsManager.sharedManager().popularTags.map( { UIImage(named: "\($0)")} )
    
    private struct CellText {
        static let FirstCell = "FIND YOUR MENTOR"
        static let SecondCell = "PAYMENT"
        static let ThirdCell = "PROMOTIONS"
        static let ForthCell = "FREE MENTOR"
        static let FifthCell = "SUPPORT"
        static let SixthCell = "ABOUT"
    }
    
    private struct CellPhoto {
        static let FirstCell = "Guru"
        static let SecondCell = "Payment"
        static let ThirdCell = "Promote"
        static let ForthCell = "Share"
        static let FifthCell = "Support"
        static let SixthCell = "Info"
    }
    
    let user = UserManager.sharedManager().user
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainCollectionView: UICollectionView! {
        didSet {
            mainCollectionView.registerNib(UINib(nibName: "MainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MainCell)
            mainCollectionView.delegate = self
            mainCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideProfile"))
            for g in mainView.gestureRecognizers as [UIGestureRecognizer] {
                g.enabled = false
            }
        }
    }
    @IBOutlet weak var profileAvatar: UIImageView! {
        didSet {
            profileAvatar.clipsToBounds = true
            profileAvatar.layer.cornerRadius = CGRectGetWidth(profileAvatar.frame)/2
            profileAvatar.fetchImage(user.profileImageURL)
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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        label.text = "Wisen"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont(name: "GillSans", size: 24)
        label.textColor = UIColor.whiteColor()  
        navigationItem.titleView = label
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: SmallAvatarWidth, height: SmallAvatarWidth))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = SmallAvatarWidth/2
        imageView.fetchImage(user.profileImageURL)
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showProfile"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: imageView)
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "segueToConfirmation");
        
        UserManager.sharedManager().user.observeAllReceivedRequestsWithBlock { (requests: [AnyObject]?) -> Void in
            if let req = requests as? [Request] {
                for r in req {
                    if r.status == .Pending {
                        self.showAlert(r, text: "You just got a new request on \(r.tag)", { accepted in
                            if accepted {
                                self.pushToMessage(r, UID: r.menteeUID, status: .MentorConfirmed)
                                UserManager.sharedManager().user.observeRequestWithID(r.requestID, block: { (request: Request!) -> Void in
                                    if request.status == .Canceled {
                                        UserManager.sharedManager().user.removeObserverWithRequestID(request.requestID)
                                        NSNotificationCenter.defaultCenter().postNotificationName(kRequestCanceledNotification, object: self, userInfo: ["request" : request])
                                    }
                                })
                            } else {
                                UserManager.sharedManager().user.updateStatus(.Canceled, forRequestWithID: r.requestID)
                            }
                        })
                        break
                    }
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRequestCompletionNote:", name: kRequestConfirmedByMentorNotification, object: nil)
    }
    
    func segueToConfirmation() {
        navigationController?.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("ConfirmationScene") as UIViewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if profileShown {
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        }
    }
    
    // MARK: Transition
    func showProfile() {
        profileShown = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        topConstraint.constant = CGRectGetHeight(backgroundView.frame)
        UIView.animateWithDuration(DefaultDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        for g in mainView.gestureRecognizers as [UIGestureRecognizer] {
            g.enabled = true
        }
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
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        profileShown = false
        for g in mainView.gestureRecognizers as [UIGestureRecognizer] {
            g.enabled = false
        }
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
            cell.avtarImageView.image = UIImage(named:CellPhoto.FirstCell)
        case 1:
            cell.titleLabel.text = CellText.SecondCell
            cell.avtarImageView.image = UIImage(named:CellPhoto.SecondCell)
        case 2:
            cell.titleLabel.text = CellText.ThirdCell
            cell.avtarImageView.image = UIImage(named:CellPhoto.ThirdCell)
        case 3:
            cell.titleLabel.text = CellText.ForthCell
            cell.avtarImageView.image = UIImage(named:CellPhoto.ForthCell)
        case 4:
            cell.titleLabel.text = CellText.FifthCell
            cell.avtarImageView.image = UIImage(named:CellPhoto.FifthCell)
        case 5:
            cell.titleLabel.text = CellText.SixthCell
            cell.avtarImageView.image = UIImage(named:CellPhoto.SixthCell)
        default:
            break
        }
        let image = cell.avtarImageView.image!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.hideProfile()
        case 1: break
        case 2: break
        case 3: break
        case 4: break
        case 5: break
        case 6: break
        default: break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Collection View Method
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MainCell, forIndexPath: indexPath) as MainCollectionViewCell
        
        cell.image = images[indexPath.item]
        if let array = TrendsManager.sharedManager().popularTags as? [String] {
            cell.titleLabel.text = array[indexPath.item]
        }
        let yOffset = ((collectionView.contentOffset.y - cell.frame.origin.y) / ImageHeight) * ImageOffsetSpeed
        cell.imageOffset = CGPointMake(0, yOffset)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TrendsManager.sharedManager().popularTags.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: CGRectGetWidth(view.frame), height: 160)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("segueToSearch", sender: indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        for view in mainCollectionView.visibleCells() as [MainCollectionViewCell] {
            let yOffset = ((mainCollectionView.contentOffset.y - view.frame.origin.y) / ImageHeight) * ImageOffsetSpeed
            view.imageOffset = CGPointMake(0, yOffset)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToSearch" {
            if let row = sender as? Int {
                if let des = segue.destinationViewController as? RequestViewController {
                    let pop = TrendsManager.sharedManager().popularTags
                    des.searchPlaceholder = row == pop.count - 1 ? "" : pop[row] as String
                }
            }
        }
    }
    
    func handleRequestCompletionNote(note: NSNotification) {
        let req: AnyObject?  = note.userInfo!["request"]
        if let request = req as? Request {
            showAlert(request, text: "We just found a match for you on \(request.tag), go ahead an say hi", completion: { accepted in
                if accepted {
                    self.pushToMessage(request, UID: request.mentorUID, status: .Ongoing)
                } else {
                    UserManager.sharedManager().user.updateStatus(.Canceled, forRequestWithID: request.requestID)
                }
            })
        }
    }

    func showAlert(request: Request, text: String, completion: (accepted: Bool)->()) {
        let alert = AMSmoothAlertView(dropAlertWithTitle: "Hey!", andText:text, andCancelButton: true, forAlertType: .Info)
        alert.completionBlock = {(alertObj: AMSmoothAlertView!, button: UIButton!) -> () in
            completion(accepted: button == alertObj.defaultButton)
        }
        alert.show()
    }
    
    func pushToMessage(req: Request, UID: NSString, status: RequestStatus) {
        UserManager.sharedManager().user.updateStatus(status, forRequestWithID: req.requestID)
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MessageScene") as MessageTableViewController
        vc.recipientUID = UID
        UserManager.sharedManager().user.currentRequest = req
        navigationController?.pushViewController(vc, animated: true)
    }
}
