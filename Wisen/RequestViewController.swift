//
//  RequestViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit
import ArcGIS

class RequestViewController: UIViewController, AGSMapViewLayerDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet var recentButtons: [UIButton]! {
        didSet {
            for button in self.recentButtons {
                button.clipsToBounds = true
                button.layer.cornerRadius = 6
                button.addTarget(self, action: "replaceSearchBar:", forControlEvents: .TouchUpInside)
            }
        }
    }
    let halo = PulsingHaloLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "updateLocation", userInfo: nil, repeats: true)
        halo.backgroundColor = UIColor.greenColor().CGColor
        halo.hidden = true
        mapView.layer.addSublayer(halo)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        mapView = nil
//    }
//    
    override func viewWillLayoutSubviews() {
        halo.position = mapView.convertPoint(mapView.center, fromView: mapView.superview)
        halo.radius = CGRectGetWidth(view.frame)
    }
    
    var searchPlaceholder: String? {
        didSet {
            searchBar?.text = searchPlaceholder
        }
    }
    
    @IBAction func gpsTouched(sender: UIButton) {
        mapView.zoomToScale(mapView.mapScale, withCenterPoint: mapView.locationDisplay.mapLocation(), animated: true)
    }

    @IBAction func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var requestButton: UIButton! {
        didSet {
            requestButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func requestButtonTouched(sender: UIButton) {
        if NSString(string: searchBar.text).length == 0 {
            return
        }
        
        let destinationPoint = mapView.toMapPoint(mapView.convertPoint(mapView.center, fromView: mapView.superview))

//        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
//        HUD.textLabel.text = @"Loading";
//        [HUD showInView:self.view];
//        [HUD dismissAfterDelay:3.0];
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "Searching"
        hud.showInView(self.view)
        hud.dismissAfterDelay(7)
        UserManager.sharedManager().user.requestWithTag(self.searchBar.text, location: self.cllocation(destinationPoint), radius: 10, block: { (request: Request?) -> Void in
            if let request = request {
                UserManager.sharedManager().user.currentRequest = request
                UserManager.sharedManager().user.observeRequestWithID(request.requestID, block: { (request: Request?) -> Void in
                    if let request = request {
                        switch request.status {
                        case .MentorConfirmed:
                            hud.dismiss()
                            self.dismissViewControllerAnimated(true, completion: {
                                NSNotificationCenter.defaultCenter().postNotificationName(kRequestConfirmedByMentorNotification, object: nil, userInfo: ["request": request])
                            })
                        case .Canceled:
                            UserManager.sharedManager().user.removeObserverWithRequestID(request.requestID)
                            hud.dismiss()
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                NSNotificationCenter.defaultCenter().postNotificationName(kRequestCanceledNotification, object: self, userInfo: ["request" : request])
                            })
                        default:
                            break;
                        }
                    }}
                )
            }
        })
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.text = searchPlaceholder
            searchBar.delegate = self
            configureSearchBar()
        }
    }
    
    @IBOutlet weak var mapView: AGSMapView! {
        didSet {
            //Add a basemap tiled layer
            let url = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
            let tiledLayer = AGSTiledMapServiceLayer(URL: url)
            mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
            mapView.layerDelegate = self
        }
    }
    
    func configureSearchBar() {
        let clearImg = imageWithColor(UIColor.clearColor(), height: 32)
        searchBar.backgroundImage = clearImg
        searchBar.setSearchFieldBackgroundImage(clearImg, forState:.Normal)
        for view in searchBar.subviews[0].subviews {
            if let textField = view as? UITextField {
                textField.textColor = UIColor.blackColor()
                textField.font = UIFont(name: "Futura-Medium", size: 17)
                textField.layer.borderColor = UIColor.whiteColor().CGColor
                textField.layer.borderWidth = 1
            }
        }
    }
  
    func imageWithColor(color :UIColor, height:CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func replaceSearchBar(button: UIButton) {
        var text = button.titleLabel!.text!
        let newText = (text as NSString).substringFromIndex(1)
        searchBar.text = newText
    }
    
    // MARK: Map Delegate Method
    func mapViewDidLoad(mapView: AGSMapView!) {
        mapView.locationDisplay.startDataSource()
        let point = mapView.locationDisplay.mapLocation()
        self.mapView.locationDisplay.autoPanMode = .Default
        self.mapView.locationDisplay.wanderExtentFactor = 0.75
    }
    
    func cllocation(from: AGSPoint) -> CLLocation {
        let loc = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(from, toSpatialReference: AGSSpatialReference.wgs84SpatialReference()) as AGSPoint
        return CLLocation(latitude: loc.y, longitude: loc.x)
    }
    
    func updateLocation() {
        if let point = mapView.locationDisplay.mapLocation() {
            UserManager.sharedManager().user.updateLocation(cllocation(point))
            TrendsManager.sharedManager().getPopularUserTagsAtLocation(cllocation(mapView.locationDisplay.mapLocation()), radius: 200, block: { (raw: [AnyObject]?) -> Void in
                if let popularTags = raw as? [String] {
                    var i = 0
                    for button in self.recentButtons {
                        if i < popularTags.count {
                            button.setTitle("#\(popularTags[i])", forState: .Normal)
                        }
                        i += 1
                    }
                    
                }
            })

        }
    }
    
    // MARK: Search Bar Method
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
