//
//  RequestViewController.swift
//  Wisen
//
//  Created by Yihe Li on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

import UIKit
import ArcGIS

class RequestViewController: UIViewController, AGSMapViewLayerDelegate, UISearchBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
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
    
    func mapViewDidLoad(mapView: AGSMapView!) {
        //do something now that the map is loaded
        //for example, show the current location on the map
        mapView.locationDisplay.startDataSource()
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
    
}
