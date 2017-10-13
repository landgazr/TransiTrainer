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
    var csvArray: [String] = []
    var previousStudent:String = ""
    var previousLocation:CLLocation = CLLocation()
    var previousTime:Date? = Date()

    
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
        
        previousLocation = currentLocation
        csvArray.append("student,inlocation,intime,outlocation,outtime\n")
    
        
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
    
    @IBAction func csvSend(_ sender: Any) {
        var str: String = ""
        for row in csvArray {
            str.append(row)
        }
        NSLog(str)
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
            let rs: RailStop = RailStop()
            NSLog((mkb.point?.coordinate.latitude.description)! + " " + (mkb.point?.coordinate.longitude.description)!)
            rs.station = mkb.placemarkData[0]
            rs.line = mkb.placemarkData[1]
            rs.status = mkb.placemarkData[2]
            rs.type = mkb.placemarkData[3]
            rs.lat = Float((mkb.point?.coordinate.latitude.description)!)!
            rs.lon = Float((mkb.point?.coordinate.longitude.description)!)!
            railStops.append(rs)
            
        }
        
        self.timestamp.text = formatter.string(from: currentDateTime).replacingOccurrences(of: ",", with: "")
        locManager.requestWhenInUseAuthorization()
        currentLocation = locManager.location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
        }

        
                let popup = PopupDialog(title: "Students", message: "Please select student.")
        var studentButtons = [DefaultButton]()
        for ssc: UITableViewCell in ss {
            let btn = DefaultButton(title: (ssc.textLabel?.text)!) {
                self.currentStudent = ssc
                self.selectedStudent.text = ssc.textLabel?.text
                self.previousTime = currentDateTime
                            }
            studentButtons.append(btn)
        }
        if( studentButtons.count > 0 ){
        popup.addButtons(studentButtons)
            
            
                self.previousStudent = self.selectedStudent.text!
                let pls: String = previousLocation.coordinate.latitude.description + " " + previousLocation.coordinate.latitude.description
                let pts: String = formatter.string(from: previousTime!).replacingOccurrences(of: ",", with: "")
                let cls: String = currentLocation.coordinate.latitude.description + " " + currentLocation.coordinate.latitude.description
                let cts: String = formatter.string(from: currentDateTime).replacingOccurrences(of: ",", with: "")
                
                let str: String = previousStudent + "," + pls + "," + pts + "," + cls + "," + cts + "\n"
                csvArray.append(str)
                
                previousLocation = currentLocation
                previousTime = currentDateTime
                previousStudent = (self.selectedStudent.text)!
                
                self.location.text = cls

            self.present(popup, animated: true, completion: nil)
            
            
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Please select students in current group.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        }
        
        
        
    }}

