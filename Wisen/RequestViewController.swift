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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "updateLocation", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    var searchPlaceholder: String? {
        didSet {
            searchBar?.text = searchPlaceholder
        }
    }
    
    @IBAction func gpsTouched(sender: UIButton) {
        mapView.zoomToScale(mapView.mapScale, withCenterPoint: mapView.locationDisplay.mapLocation(), animated: true)
    }
    
    @IBOutlet weak var recentSecondButton: UIButton! {
        didSet {
            recentSecondButton.clipsToBounds = true
            recentSecondButton.layer.cornerRadius = 6
            recentSecondButton.addTarget(self, action: "replaceSearchBar:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var recentFirstButton: UIButton! {
        didSet {
            recentFirstButton.clipsToBounds = true
            recentFirstButton.layer.cornerRadius = 6
            recentFirstButton.addTarget(self, action: "replaceSearchBar:", forControlEvents: .TouchUpInside)
        }
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
//        let currentPoint = mapView.locationDisplay.mapLocation()
        let destinationPoint = mapView.toMapPoint(mapView.convertPoint(mapView.center, fromView: mapView.superview))
//        NSLog("Current: \(currentPoint) + Destination: \(destinationPoint)")
        
//        let cur = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(currentPoint, toSpatialReference: AGSSpatialReference.wgs84SpatialReference()) as AGSPoint
//        let dest = AGSGeometryEngine.defaultGeometryEngine().projectGeometry(destinationPoint, toSpatialReference: AGSSpatialReference.wgs84SpatialReference()) as AGSPoint
//        NSLog("Cur: \(cur) + Dest: \(dest)")

        dismissViewControllerAnimated(true, completion: { ()
            UserManager.sharedManager().user.requestWithTag(self.searchBar.text, location: self.cllocation(destinationPoint), radius: 10)

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
                textField.font = UIFont(name: "GillSans", size: 17)
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
        searchBar.text = button.titleLabel?.text
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
        }
    }
    
    // MARK: Search Bar Method
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
