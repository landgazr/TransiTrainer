//
//  MapViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 12/2/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    var mvc:MainlineViewController!
    @IBOutlet weak var locLabel: UILabel!
    
    @IBOutlet weak var mapView:MKMapView!
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.mvc.dismissDialog()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is MainlineViewController) {
                    mvc = viewController as! MainlineViewController
                }}}
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create and Add MapView to our main view
        createMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userLocation:CLLocation = mvc.locManager.location!
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        
        mapView.addAnnotation(myAnnotation)
        
        let cs:CurrentMapLocation = mvc.returnCurrentLocation()!
        
        let closestAnnotation: MKPointAnnotation = MKPointAnnotation()
        closestAnnotation.coordinate = CLLocationCoordinate2DMake(cs.rs.latlon.coordinate.latitude, cs.rs.latlon.coordinate.longitude);
        closestAnnotation.title = cs.rs.station
        
        locLabel.text = cs.rs.station + " (currently" + cs.courseStr + ")"
        
        mapView.addAnnotation(closestAnnotation)
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func createMapView()
    {
        //mapView = MKMapView()
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        mapView.center = view.center
        
        view.addSubview(mapView)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
}
