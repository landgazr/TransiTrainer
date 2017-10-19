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


class MainlineViewController: UIViewController, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var locManager = CLLocationManager()
    var avc: AddingViewController = AddingViewController()
    var ss = [UITableViewCell]()
    var currentStudent = UITableViewCell()
    
    @IBOutlet weak var trainerLabel: UILabel!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    
    //@IBOutlet weak var location: UILabel!
    @IBOutlet weak var selectedStudent: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    var inStation: Bool = false
    var inLine: Bool = false
    var inStatus: Bool = false
    var inType: Bool = false
    var railStops: [RailStop] = []
    var csvArray: [String] = []
    var previousStudent:String = ""
    static var previousLocation:CLLocation = CLLocation()
    var previousTime:Date? = Date()
    var previousStop:String = ""
    var currentStop:String = ""
    var todaysDate:String = ""
    
    var namesOfTrainers = [Int: String]()
    static var trainerArr: [String] = [String]()
    
    func closestLocation(locations: [CLLocation], closestToLocation location: CLLocation) -> CLLocation? {
        if let closestLocation = locations.min(by: { location.distance(from: $0) < location.distance(from: $1) }) {
            return closestLocation
        } else {
            print("coordinates is empty")
            return nil
        }
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if( row == 0 ){
            self.trainerLabel.text = "No trainer selected"
        } else {
        self.trainerLabel.text = MainlineViewController.trainerArr[row - 1]
             }
    }
    
    
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MainlineViewController.trainerArr.count + 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "" : MainlineViewController.trainerArr[row - 1]
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showCurrentLocation() {
        
        var stopCoords: CLLocation = CLLocation()
        var arr: [CLLocation] = [CLLocation]()
        for rs in railStops {
            arr.append(rs.latlon)
        }
        if (railStops.count > 0) {
        locManager.requestWhenInUseAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            stopCoords = (self.closestLocation(locations: arr, closestToLocation: locManager.location!))!
            
        }
        
        for rs in railStops {
            if (rs.latlon.distance(from: stopCoords) == 0) {
                self.currentStop = rs.station
                break
            }
        }

        let myAlert = UIAlertController(title: "Information", message: self.currentStop, preferredStyle: .alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        self.show(myAlert, sender: self)
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Please select a starting student to show location.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            self.show(myAlert, sender: self)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        namesOfTrainers[6661] = "Stone/Krista"
        namesOfTrainers[4950] = "Ulabarro/Jorge"
        namesOfTrainers[4990] = "Herring/Anthony"
        namesOfTrainers[1018] = "Lynch/Bob"
        namesOfTrainers[695]  = "Palmblad/Marylin"
        namesOfTrainers[5083] = "Varcoe/Keary"
        namesOfTrainers[5026] = "Carothers/Jewel"
        namesOfTrainers[3861] = "Hilliard/James"
        namesOfTrainers[5832] = "Harris/Charles"
        namesOfTrainers[5948] = "Banegas Cruz/Shila"
        namesOfTrainers[6365] = "Hull/Jason"
        namesOfTrainers[6749] = "Nelson/Steven"
        namesOfTrainers[7117] = "Milford/Margaret"
        namesOfTrainers[1426] = "Carothers/Matthew"
        namesOfTrainers[2852] = "Ruiz/David"
        namesOfTrainers[7244] = "Saleib/Moheb"
        
        self.picker.dataSource = self
        self.picker.delegate = self
        
        
        
                for (_, v) in namesOfTrainers {
            MainlineViewController.trainerArr.append(v)
        }
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
       
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            NSLog((locManager.location?.coordinate.latitude.description)!)
            NSLog((locManager.location?.coordinate.longitude.description)!)
        }
        
        locManager.startUpdatingLocation()
        
        
        
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        self.todaysDate = dateFormatter.string(from: date)
        
        csvArray.append("date,student,inlocation,intime,outlocation,outtime,totaltime\n")


        
        self.view.backgroundColor = getBackgroundColor(hour: hour)
    
        
    }
    
        
    func getBackgroundColor(hour:Int) -> UIColor {
        
        
        let morning = UIColor(red: 255/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
        let noon = UIColor(red: 200/255.0, green: 200/255.0, blue: 255/255.0, alpha: 1.0)
        let night = UIColor(red: 200/255.0, green: 255/255.0, blue: 200/255.0, alpha: 1.0)
        switch hour {
        case 7...11:   // 7am-11am
            return morning
        case 12...16:  // 12pm-4pm
            return noon
        default:
            return night
        }
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
                
                let body = self.trainerLabel.text! + "\n Car # " + self.carLabel.text! + "\n Train ID " + self.trainLabel.text!
                
                let date : Date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                let todaysDate = dateFormatter.string(from: date)
                
                if MFMailComposeViewController.canSendMail()
                {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self;
                mail.setToRecipients(["mumbuns@yahoo.com"])
                mail.setCcRecipients(["landgazr@gmail.com"])
                mail.setSubject("Training Record " + self.trainerLabel.text! + " " + todaysDate)
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
        if (railStops.count > 0) {
            
            var stopCoords: CLLocation = CLLocation()
            var arr: [CLLocation] = [CLLocation]()
            for rs in railStops {
                arr.append(rs.latlon)
            }
            if (railStops.count > 0) {
                locManager.requestWhenInUseAuthorization()
                if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                    stopCoords = closestLocation(locations: arr, closestToLocation: locManager.location!)!
                
                }
                
                for rs in railStops {
                    if (rs.latlon.distance(from: stopCoords) == 0) {
                        self.currentStop = rs.station
                        //self.previousStop = rs.station
                        break
                    }
                }

        
            self.selectedStudent.text = "None"
       
        let s: String = (self.currentStudent.textLabel?.text)!
        let currentTime: Date = Date()
        let pls: String = previousStop
        let pts: String = formatter.string(from: self.previousTime!).replacingOccurrences(of: ",", with: "")
        let cls: String = self.currentStop
        let cts: String = formatter.string(from: currentTime).replacingOccurrences(of: ",", with: "")
                
            
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
                
    let ttm = formatter.string(from: currentTime.timeIntervalSince(self.previousTime!))!
        
        //self.timestamp.text = formatter.string(from: Date()).replacingOccurrences(of: ",", with: "")
        //self.location.text = cls
        
        let str: String = self.todaysDate + "," + s + "," + pls + "," + pts + "," + cls + "," + cts + "," + ttm + "\n"
        self.csvArray.append(str)
        NSLog(str)
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Please select a starting student to show location.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            self.show(myAlert, sender: self)        }

    }
    }
  
    @IBAction func setTrainer(_ sender: Any)
    {
        
        
        let myAlert = UIAlertController(title: "Information", message: "Enter car #/train ID.", preferredStyle: .alert);
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            // Get 1st TextField's text
            var sa: [String] = [String]()
            for utf in myAlert.textFields! {
                sa.append(utf.text!)
            }
            self.carLabel.text = sa[0]
            self.trainLabel.text = sa[1]
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
    
       
    @IBAction func actionAlert(_ sender: Any) {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        
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
        
        
        
        
        var stopCoords: CLLocation = CLLocation()
        var arr: [CLLocation] = [CLLocation]()
        for rs in railStops {
            arr.append(rs.latlon)
        }
        if (railStops.count > 0) {
            locManager.requestWhenInUseAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                stopCoords = (self.closestLocation(locations: arr, closestToLocation: locManager.location!))!
                
            }
            
            for rs in railStops {
                if (rs.latlon.distance(from: stopCoords) == 0) {
                    self.previousStop = rs.station
                    break
                }
            }


        
        let popup = PopupDialog(title: "Students", message: "Please select student.")
        var studentButtons = [DefaultButton]()
        ss = avc.svc.getSelectedStudents()
        for ssc: UITableViewCell in ss {
            let btn = DefaultButton(title: (ssc.textLabel?.text)!) {
                self.currentStudent = ssc
                self.selectedStudent.text = ssc.textLabel?.text
                MainlineViewController.previousLocation = self.locManager.location!
                self.previousTime = currentDateTime
                self.previousStudent = (self.selectedStudent.text)!
            
            }
            studentButtons.append(btn)
        }
            
            let btn = DefaultButton(title: (trainerLabel.text)!) {
                self.currentStudent = UITableViewCell()
                self.currentStudent.textLabel?.text = self.trainerLabel.text
                self.selectedStudent.text = self.trainerLabel.text
                MainlineViewController.previousLocation = self.locManager.location!
                self.previousTime = currentDateTime
                self.previousStudent = (self.selectedStudent.text)!
                
            }

                studentButtons.append(btn)
            
        
        
        if( studentButtons.count > 0 ){
        popup.addButtons(studentButtons)
            
            
            
            self.present(popup, animated: true, completion: nil)
            
            
            
        }
        
        else {
            let myAlert = UIAlertController(title: "Information", message: "Please select students in current group.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        
        }
        
        
        
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Could not get location.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)        }

        }}

