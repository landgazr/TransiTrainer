//
//  FirstViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 8/27/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FirstViewController: UIViewController {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()
        currentLocation = locManager.location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            NSLog(currentLocation.coordinate.latitude.description)
            NSLog(currentLocation.coordinate.longitude.description)
        }
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that nevertheless can be recreated.
        
    }
    
    
    @IBAction func actionAlert(_ sender: Any) {
        let myAlert = UIAlertController(title: "Alert", message: "This is an alert.", preferredStyle: .alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        show(myAlert, sender: self)
        let filepath = Bundle.main.path(forResource: "tm_rail_stops", ofType: "kml")
        let u: URL = URL.init(fileURLWithPath: filepath!)
        var kp: KMLParser = KMLParser(url: u)
        kp.parseKML()
        for mka in kp.points {
            NSLog(mka.coordinate.latitude.description + " " + mka.coordinate.longitude.description)
        }
        NSLog("done")
    }}

