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

class RailStop {
    var station:String = ""
    var line:String = ""
    var status:String = ""
    var type:String = ""
    var lat:Float = 0.0
    var lon:Float = 0.0
}


class MainlineViewController: UIViewController {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var svc: StudentsViewController = StudentsViewController()
    var ss = [UITableViewCell]()
    var currentStudent = UITableViewCell()
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var selectedStudent: UILabel!
    var inStation: Bool = false
    var inLine: Bool = false
    var inStatus: Bool = false
    var inType: Bool = false
    var railStops: [RailStop] = []
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is StudentsViewController) {
                    svc = viewController as! StudentsViewController
                    ss = svc.getSelectedStudents()
                }
            }
            
        }

    }
  
    
    
    @IBAction func actionAlert(_ sender: Any) {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        
        
        //let myAlert = UIAlertController(title: "Alert", message: "This is an alert.", preferredStyle: .alert);
        //myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        //show(myAlert, sender: self)
        let filepath = Bundle.main.path(forResource: "tm_rail_stops", ofType: "kml")
        let u: URL = URL.init(fileURLWithPath: filepath!)
        let kp: KMLParser = KMLParser(url: u)
        kp.parseKML()
        
            for mkb in kp.placemarks {
            var rs: RailStop = RailStop()
            NSLog((mkb.point?.coordinate.latitude.description)! + " " + (mkb.point?.coordinate.longitude.description)!)
            rs.station = mkb.placemarkData[0]
            rs.line = mkb.placemarkData[1]
            rs.status = mkb.placemarkData[2]
            rs.type = mkb.placemarkData[3]
            rs.lat = Float((mkb.point?.coordinate.latitude.description)!)!
            rs.lon = Float((mkb.point?.coordinate.longitude.description)!)!
            railStops.append(rs)
            
        }
                let popup = PopupDialog(title: "Students", message: "Please select student.")
        var studentButtons = [DefaultButton]()
        for ssc: UITableViewCell in ss {
            let btn = DefaultButton(title: (ssc.textLabel?.text)!) {
                self.currentStudent = ssc
                self.selectedStudent.text = ssc.textLabel?.text
            }
            studentButtons.append(btn)
        }
        if( studentButtons.count > 0 ){
        popup.addButtons(studentButtons)
            self.present(popup, animated: true, completion: nil)
            self.timestamp.text = formatter.string(from: currentDateTime)
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Please select students in current group.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        }
        
    }}

