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
import MessageUI

class RailStop {
    var station:String = ""
    var line:String = ""
    var status:String = ""
    var type:String = ""
    var latlon:CLLocation = CLLocation()
    
}


class MainlineViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var avc: AddingViewController = AddingViewController()
    var ss = [UITableViewCell]()
    var currentStudent = UITableViewCell()
    
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    
    //@IBOutlet weak var location: UILabel!
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
    var previousStop:String = ""
    var currentStop:String = ""

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
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
        
        
        csvArray.append("student,inlocation,intime,outlocation,outtime\n")
    
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is AddingViewController) {
                    avc = viewController as! AddingViewController
                    ss = avc.svc.getSelectedStudents()                }
            }
            
        }

    }
    
    @IBAction func csvSend(_ sender: Any) {
        var str: String = ""
        
        for row in csvArray {
            str.append(row)
        }
        let file = "file.csv" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                
            
            if(FileManager.default.fileExists(atPath: fileURL.path)){
                try FileManager.default.removeItem(atPath: fileURL.path)
                } } catch {}

            do {
                try str.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {/* error handling here */}
        
            do {
        
           
                
                let csvdata: NSData = try NSData(contentsOf: fileURL, options: .alwaysMapped)
                let csvatt: Data = csvdata as Data
                
                let body = self.trainerLabel.text! + "\n" + self.carLabel.text! + "\n" + self.trainLabel.text!
                
                if MFMailComposeViewController.canSendMail()
                {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self;
                mail.setCcRecipients(["one@two.com"])
                mail.setSubject("Training Subject")
                mail.setMessageBody(body, isHTML: false)
                mail.addAttachmentData(csvatt, mimeType: "text/csv", fileName: "file.csv")
                self.present(mail, animated: true, completion: nil)
                } else {
                    let myAlert = UIAlertController(title: "Information", message: "Cannot send mail with this device.", preferredStyle: .alert);
                    myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
                    show(myAlert, sender: self)

                }

            }
            catch {}
            
            
            //reading
            //do {
            //    let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            //}
            //catch {/* error handling here */}
        }
        
        avc.svc.writeRoster()
        
        }
    
    @IBAction func actionAlertOut(_ sender: Any)
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short

        locManager.requestWhenInUseAuthorization()
        currentLocation = locManager.location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
        }
        
        var arr: [CLLocation] = [CLLocation]()
        for rs in railStops {
            arr.append(rs.latlon)
        }
        let stopCoords: CLLocation = (closestLocation(locations: arr, closestToLocation: currentLocation))!
        for rs in railStops {
            if (rs.latlon.distance(from: stopCoords) == 0) {
                currentStop = rs.station
                break
            }
        }
        
        self.selectedStudent.text = "None"
       
        let s: String = (self.currentStudent.textLabel?.text)!
        
        let pls: String = previousStop
        let pts: String = formatter.string(from: self.previousTime!).replacingOccurrences(of: ",", with: "")
        let cls: String = currentStop
        let cts: String = formatter.string(from: Date()).replacingOccurrences(of: ",", with: "")
        
        //self.timestamp.text = formatter.string(from: Date()).replacingOccurrences(of: ",", with: "")
        //self.location.text = cls
        
        let str: String = s + "," + pls + "," + pts + "," + cls + "," + cts + "\n"
        self.csvArray.append(str)
        NSLog(str)

    }
  
    @IBAction func setTrainer(_ sender: Any)
    {
        
        
        let myAlert = UIAlertController(title: "Information", message: "Enter trainer/car #/train ID.", preferredStyle: .alert);
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            var sa: [String] = [String]()
            for utf in myAlert.textFields! {
                sa.append(utf.text!)
            }
            self.trainerLabel.text = sa[0]
            self.carLabel.text = sa[1]
            self.trainLabel.text = sa[2]
        })
        myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Trainer name"
        })
        myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Car number"
        })
        myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Train ID"
        })
        //myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        myAlert.addAction(okAction)
        show(myAlert, sender: self)
        
        
    }
    
    func closestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
        if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
            return closestLocation
        } else {
            print("coordinates is empty")
            return nil
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
            let rs: RailStop = RailStop()
            NSLog((mkb.point?.coordinate.latitude.description)! + " " + (mkb.point?.coordinate.longitude.description)!)
            rs.station = mkb.placemarkData[0]
            rs.line = mkb.placemarkData[1]
            rs.status = mkb.placemarkData[2]
            rs.type = mkb.placemarkData[3]
            
                let lat: Double = Double((mkb.point?.coordinate.latitude.description)!)!
                let lon: Double = Double((mkb.point?.coordinate.longitude.description)!)!
                let latdeg: CLLocationDegrees = CLLocationDegrees(lat)
                let londeg: CLLocationDegrees = CLLocationDegrees(lon)
                let loc: CLLocation = CLLocation(latitude: latdeg, longitude: londeg)
                
                rs.latlon = loc
                railStops.append(rs)
            
        }
        
        //self.timestamp.text = formatter.string(from: currentDateTime).replacingOccurrences(of: ",", with: "")
        
        
        
        
        locManager.requestWhenInUseAuthorization()
        currentLocation = locManager.location
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
        }
        
        var arr: [CLLocation] = [CLLocation]()
        
        for rs in railStops {
            arr.append(rs.latlon)
        }

        
        let stopCoords: CLLocation = (closestLocation(locations: arr, closestToLocation: currentLocation))!
        //let cls: String = self.currentLocation.coordinate.latitude.description + " " + self.currentLocation.coordinate.latitude.description
        //self.location.text = cls
        

        
        let popup = PopupDialog(title: "Students", message: "Please select student.")
        var studentButtons = [DefaultButton]()
        for ssc: UITableViewCell in ss {
            let btn = DefaultButton(title: (ssc.textLabel?.text)!) {
                self.currentStudent = ssc
                self.selectedStudent.text = ssc.textLabel?.text
                self.previousLocation = self.currentLocation
                self.previousTime = currentDateTime
                self.previousStudent = (self.selectedStudent.text)!
                for rs in self.railStops {
                    if (rs.latlon.distance(from: stopCoords) == 0) {
                        self.previousStop = rs.station
                    }
                }

                
            
            }
            studentButtons.append(btn)
        }
        
        if( studentButtons.count > 0 ){
        popup.addButtons(studentButtons)
            
            
            
            self.present(popup, animated: true, completion: nil)
            
            
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Please select students in current group.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        }
        
        
        
    }}

