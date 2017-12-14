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

class CurrentMapLocation {
    var rs:RailStop = RailStop()
    var courseStr:String = ""
}

class RailStop {
    var station:String = ""
    var line:String = ""
    var status:String = ""
    var type:String = ""
    var latlon:CLLocation = CLLocation()
    
}

class RailStation {
    var station:RailStop? = RailStop()
    var arrivalTime:Date? = Date()
    var course:String = ""
}

struct Queue<T> {
    var list = [T]()

    mutating func enqueue(_ element: T) {
        list.append(element)
    }
    
    mutating func dequeue() -> T? {
        if !list.isEmpty {
            return list.removeFirst()
        } else {
            return nil
        }
    }
    
    func peek() -> T? {
        if !list.isEmpty {
            return list[0]
        } else {
            return nil
        }
    }
    
    var isEmpty: Bool {
        return list.isEmpty
    }
    
    func count() -> Int {
        return list.count
    }
    
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
    @IBOutlet weak var coupled: UISegmentedControl!
    
    var inStation: Bool = false
    var inLine: Bool = false
    var inStatus: Bool = false
    var inType: Bool = false
    var railStops: [RailStop] = []
    var railStopsLL: [CLLocation] = []
    var csvArray: [String] = []
    var tripArray: [String] = []
    var previousStudent:String = ""
    static var previousLocation:CLLocation = CLLocation()
    var previousTime:Date? = Date()
    var previousStop:String = ""
    var previousCourse:String = ""
    var currentStop:String = ""
    var currentStation:RailStop = RailStop()
    var todaysDate:String = ""
    var stationsVisited = OrderedDictionary<String, RailStation>()
    
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
    
    @IBAction func segmentedControlAction(sender: AnyObject) {
        /*if(segmentedControl.selectedSegmentIndex == 0)
        {
            textLabel.text = "First Segment Selected";
        }
        else if(segmentedControl.selectedSegmentIndex == 1)
        {
            textLabel.text = "Second Segment Selected";
        }
        else if(segmentedControl.selectedSegmentIndex == 2)
        {
            textLabel.text = "Third Segment Selected";
        }*/
    }


    func reconcile(student: String, inLocation: RailStation, outLocation: RailStation, couple: Int) {
        if( self.selectedStudent.text != "None" ) {
            
            self.selectedStudent.text = "None"
            
            let s: String = (self.currentStudent.textLabel?.text)!
            let currentTime: Date = inLocation.arrivalTime!
            let pls: String = previousStop + previousCourse
            //let pts: String = formatter.string(from: self.previousTime!).replacingOccurrences(of: ",", with: "")
            let cls: String = (inLocation.station?.station)! + inLocation.course
            //let cts: String = formatter.string(from: currentTime).replacingOccurrences(of: ",", with: "")
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            var cpl:String = ""
            
            if( self.coupled.selectedSegmentIndex == 0)
            {
                cpl = "uncoupled"
            }
            else if( self.coupled.selectedSegmentIndex == 2)
            {
                cpl = "coupled"
            }
            else
            {
                cpl = "none"
            }
            
            let ttm = formatter.string(from: currentTime.timeIntervalSince(self.previousTime!))!
            
            let fmtr: DateFormatter = DateFormatter()
            fmtr.dateFormat = "HH:mm"
            let str: String = self.todaysDate + "," + s + "," + pls + "," + fmtr.string(from: self.previousTime!) + "," + cls + "," + fmtr.string(from: currentTime) + "," + ttm + "," + cpl + "\n"
            self.csvArray.append(str)
            NSLog(str)
            self.coupled.selectedSegmentIndex = 1
        }
        
        var cpl:String = ""
        
        if( couple == 0)
        {
            cpl = "uncoupled"
        }
        else if( couple == 2)
        {
            cpl = "coupled"
        }
        else
        {
            cpl = "none"
        }
        let fmtr: DateFormatter = DateFormatter()
        fmtr.dateFormat = "HH:mm"
        
        let inKey = (inLocation.station?.station)! + "@" + fmtr.string(from: inLocation.arrivalTime!)
        let outKey = (outLocation.station?.station)! + "@" + fmtr.string(from: outLocation.arrivalTime!)
        
        let locationIn: RailStation =  self.stationsVisited[inKey]!
        let locationOut: RailStation = self.stationsVisited[outKey]!
        
        //MainlineViewController.stationsVisited.dict.removeValue(forKey: (inLocation.station?.station)!)
        //MainlineViewController.stationsVisited.dict.removeValue(forKey: (outLocation.station?.station)!)
        
        let ils: String = (locationIn.station?.station)! + locationIn.course
        //let pts: String = formatter.string(from: self.previousTime!).replacingOccurrences(of: ",", with: "")
        let ols: String = (locationOut.station?.station)! + locationOut.course
        //let cts: String = formatter.string(from: currentTime).replacingOccurrences(of: ",", with: "")
        
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let ttm = formatter.string(from: (outLocation.arrivalTime?.timeIntervalSince(inLocation.arrivalTime!))!)!
        
        let str: String = self.todaysDate + "," + student + "," + ils + "," + fmtr.string(from: inLocation.arrivalTime!) + "," + ols + "," + fmtr.string(from: outLocation.arrivalTime!) + "," + ttm + "," + cpl + "\n"
        self.csvArray.append(str)
        self.previousCourse = outLocation.course
        self.previousStop = (outLocation.station?.station)!
        NSLog(str)
        
    }
    
    func cardinalDirection(closestToLocation location: CLLocation) -> String? {
        
        if( location.course >= 44.0 && location.course < 135.0 )
        {
            return " EB"
        }
        else if( location.course >= 135.0 && location.course < 225.0 )
        {
            return " SB"
        }
        else if( location.course >= 225.0 && location.course < 315.0 )
        {
            return " WB"
        }
        else
        {
            return " NB"
        }
        /*let dirs = [" NB", " EB", " SB", " WB", " NB"]
        
        let degreesPerDir: Double = 360.0 / Double((dirs.count - 1))
        let cld: CLLocationDirection = location.course
        let index: Int = Int((cld + (degreesPerDir / 2.0)) / degreesPerDir)
        return dirs[index]*/
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
        
        if( result == MFMailComposeResult.sent )
        {
            csvArray.removeAll()
            csvArray.append("date,student,inlocation,intime,outlocation,outtime,timeinseat,coupling\n")
            tripArray.removeAll()
            tripArray.append("student,station,totaltimeto\n")
        }
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
    //@IBAction func addRetroactiveStudent() {
    //    self.showDialog(LSAnimationPattern.fadeInOut)
    //}
    
    @IBAction func showCurrentMap() {
        self.showMap(LSAnimationPattern.fadeInOut)
    }
    
    
    
    @objc func getCurrentStation() {
        var stopCoords: CLLocation = CLLocation()
        var course: String = ""
        
        let fmtr: DateFormatter = DateFormatter()
        fmtr.dateFormat = "HH:mm"
        
        
        if (railStops.count > 0) {
            locManager.requestWhenInUseAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                let loc = locManager.location!
                stopCoords = (self.closestLocation(locations: railStopsLL, closestToLocation: loc))!
                course = cardinalDirection(closestToLocation: loc)!
                
                for rs in railStops {
                    if (rs.latlon.distance(from: stopCoords) == 0) {
                        self.currentStation = rs
                        break
                    }
                }
                if( loc.distance(from: self.currentStation.latlon) < 50.0 && loc.speed < 2.0) {
                    let station:RailStation = RailStation()
                    station.arrivalTime = Date()
                    station.station = self.currentStation
                    station.course = course
                    
                  
                    if( self.stationsVisited.count > 0 ) {
                        
                        let previousStationKey = self.stationsVisited.keys[self.stationsVisited.count - 1]
                        let previousStationVal: RailStation = self.stationsVisited[previousStationKey]!
                        
                        //if we are not lingering at the same station...
                        if( previousStationVal.station?.station != station.station?.station)
                        {
                            
                            let key = (station.station?.station)! + "@" + fmtr.string(from: station.arrivalTime!)
                            self.stationsVisited[key] = station
                            
                            /*let formatter = DateComponentsFormatter()
                            formatter.allowedUnits = [.hour, .minute, .second]
                            formatter.unitsStyle = .positional
                            formatter.zeroFormattingBehavior = .pad
                            
                            
                            let ttm = formatter.string(from: (station.arrivalTime?.timeIntervalSince(previousStationVal.arrivalTime!))!)!
                            
                            let stn: String = (station.station?.station)! + ","
                            var sls: String = ""
                            
                            if( self.selectedStudent.text! == "None" )
                            {
                                sls = self.previousStudent
                            }
                            else
                            {
                                sls = self.selectedStudent.text! + ","
                            }
                            
                            //let rowStr = sls + stn + ttm + "\n"
                            //self.tripArray.append(rowStr)
                            */
                        }
                    }
                    else
                    {
                        let key = (station.station?.station)! + "@" + fmtr.string(from: station.arrivalTime!)
                        
                        self.stationsVisited[key] = station
                        //self.tripArray.append(self.selectedStudent.text! + "," + (station.station?.station)! + ",0:00:00" + "\n")
                        
                    }
                }
            }
        }
    }
    
    func returnCurrentLocation() -> CurrentMapLocation? {
    
        var stopCoords: CLLocation = CLLocation()
        var course: String = ""
        
    if (railStops.count > 0) {
        locManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            let loc = locManager.location!
            stopCoords = (self.closestLocation(locations: railStopsLL, closestToLocation: loc))!
            course = cardinalDirection(closestToLocation: loc)!
    
            for rs in railStops {
                if (rs.latlon.distance(from: stopCoords) == 0) {
                    let toReturn:CurrentMapLocation = CurrentMapLocation()
                    toReturn.rs = rs
                    toReturn.courseStr = course
                    return toReturn
                    
    }
    }
    }
    }
    
        return CurrentMapLocation()
    
    }
    
    
    @IBAction func showCurrentLocation() {
        
        var stopCoords: CLLocation = CLLocation()
        var course: String = ""
        
        if (railStops.count > 0) {
            locManager.requestWhenInUseAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                let loc = locManager.location!
                stopCoords = (self.closestLocation(locations: railStopsLL, closestToLocation: loc))!
                course = cardinalDirection(closestToLocation: loc)!
                
                for rs in railStops {
                    if (rs.latlon.distance(from: stopCoords) == 0) {
                        let msg = rs.station + course
                        
                        let myAlert = UIAlertController(title: "Information", message: msg, preferredStyle: .alert);
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
                        self.show(myAlert, sender: self)
                        break
                    }
                }
            }
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
       
     /*       if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            NSLog((locManager.location?.coordinate.latitude.description)!)
            NSLog((locManager.location?.coordinate.longitude.description)!)
        }
        */
        
        locManager.startUpdatingLocation()
        locManager.startUpdatingHeading()
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        self.todaysDate = dateFormatter.string(from: date)
        
        csvArray.append("date,student,inlocation,intime,outlocation,outtime,timeinseat,coupling\n")
        tripArray.append("student,station,totaltimeto\n")

        
        self.view.backgroundColor = getBackgroundColor(hour: hour)
        self.selectedStudent.text = "None"
        
        let filepath = Bundle.main.path(forResource: "tm_rail_stops", ofType: "kml")
        let u: URL = URL.init(fileURLWithPath: filepath!)
        let kp: KMLParser = KMLParser(url: u)
        kp.parseKML()
        
        for mkb in kp.placemarks {
            let rs: RailStop = RailStop()
            //NSLog((mkb.point?.coordinate.latitude.description)! + " " + (mkb.point?.coordinate.longitude.description)!)
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
        
        for rs in railStops {
            railStopsLL.append(rs.latlon)
        }
        
        var timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.getCurrentStation), userInfo: nil, repeats: true)
        
       

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
        var tripStr: String = ""
        
        var currentCsvRow: Int = 1
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        var record:String = csvArray[currentCsvRow]
        var recordRow:[String] = record.components(separatedBy: ",")
        
        var start = recordRow[2].index(recordRow[2].startIndex, offsetBy: 0)
        var end = recordRow[2].index(recordRow[2].endIndex, offsetBy: -3)
        var range = start..<end
        var inStn:String = String(recordRow[2][range])
        
        var startOut = recordRow[4].index(recordRow[4].startIndex, offsetBy: 0)
        var endOut = recordRow[4].index(recordRow[4].endIndex, offsetBy: -3)
        var rangeOut = startOut..<endOut
        var outStn:String = String(recordRow[4][rangeOut])
        
        var flag: Bool = false
        var switchAtStation: Bool!
        var prev:RailStation = RailStation()
        var loc = ""
        var ttt = ""
        var std = ""
        var cnt = 0
        
        //begin creating trip log from final CSV array
        stationLoop: while(cnt < stationsVisited.count)
        {
            //get station under consideration
            let key = stationsVisited.keys[cnt]
            let visited:RailStation = stationsVisited[key]!
         
            switchAtStation = false
            /* now var "visited" is one station ahead of var "prev"
            which in essence simulates next stop on the route */
            
            if( !flag ) //if we are not processing a student's visited stations...
            {
                if( visited.station?.station == inStn ) //...start doing so if we are at the student's in-seat location
                {
                    flag = true
                    loc = inStn
                    prev = visited
                    std = recordRow[1]
                }
            }
            else //we are already processing a student's visited stations, so...
            {
                if( visited.station?.station == outStn ) //...if we are at the student's out-of-seat location...
                {
                    //...get them out
                    flag = false
                    loc = outStn
                    
                    //set up for next iteration
                    currentCsvRow += 1
                    
                    
                    
                    if( currentCsvRow < csvArray.count) {
                        record = csvArray[currentCsvRow]
                        recordRow = record.components(separatedBy: ",")
                        
                        start = recordRow[2].index(recordRow[2].startIndex, offsetBy: 0)
                        end = recordRow[2].index(recordRow[2].endIndex, offsetBy: -3)
                        range = start..<end
                        inStn = String(recordRow[2][range])
                        
                        //if new inStation is the same as old outStation
                        //then "stay" at this station
                        if( outStn == inStn )
                        {
                            switchAtStation = true
                        }
                        
                        
                        startOut = recordRow[4].index(recordRow[4].startIndex, offsetBy: 0)
                        endOut = recordRow[4].index(recordRow[4].endIndex, offsetBy: -3)
                        rangeOut = startOut..<endOut
                        outStn = String(recordRow[4][rangeOut])
                    }
                }
            }
            
            
            //do not execute if we are at a student's
            //starting point since they haven't traveled anywhere
            if( prev.station?.station != visited.station?.station) {
                loc = (visited.station?.station)!
                ttt = formatter.string(from: (visited.arrivalTime?.timeIntervalSince(prev.arrivalTime!))!)!
                let str = std + "," + loc + "," + ttt + "\n"
                tripArray.append(str)
            }
            
            
            if( switchAtStation )
            {
                continue
            }
            else
            {
                prev = visited
                cnt += 1
            }
        }
        
        for csv in csvArray {
            str.append(csv)
        }
        
        for trip in tripArray {
            tripStr.append(trip)
        }
        
        NSLog(str)
        NSLog(tripStr)
        
        
        let file = "trainingRecord.csv" //this is the file. we will write to and read from it
        let tripFile = "tripLog.csv"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            let tripFileURL = dir.appendingPathComponent(tripFile)
            
            do {
                
            
            if(FileManager.default.fileExists(atPath: fileURL.path)){
                try FileManager.default.removeItem(atPath: fileURL.path)
                try FileManager.default.removeItem(atPath: tripFileURL.path)
                } } catch {}

            do {
                try str.write(to: fileURL, atomically: false, encoding: .utf8)
                try tripStr.write(to: tripFileURL, atomically: false, encoding: .utf8)
            } catch {/* error handling here */}
        
            do {
        
           
                
                let csvdata: NSData = try NSData(contentsOf: fileURL, options: .alwaysMapped)
                let tripdata: NSData = try NSData(contentsOf: tripFileURL, options: .alwaysMapped)
                let csvatt: Data = csvdata as Data
                let tripatt: Data = tripdata as Data
                
                let body = self.trainerLabel.text! + "\n Car # " + self.carLabel.text! + "\n Train ID " + self.trainLabel.text!
                
                let date : Date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                let todaysDate = dateFormatter.string(from: date)
                
                if MFMailComposeViewController.canSendMail()
                {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self;
                mail.setToRecipients(["VarcoeK@trimet.org"])
                mail.setCcRecipients(["JonesRI@trimet.org"])
                mail.setSubject("Training Record " + self.trainerLabel.text! + " " + todaysDate)
                mail.setMessageBody(body, isHTML: false)
                mail.addAttachmentData(csvatt, mimeType: "text/csv", fileName: "trainingRecord.csv")
                mail.addAttachmentData(tripatt, mimeType: "text/csv", fileName: "tripLog.csv")
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
        
        //avc.svc.writeRoster()
        
        }
    
    @IBAction func actionAlertOut(_ sender: Any)
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
       
        var course: String = ""
            var stopCoords: CLLocation = CLLocation()
            var arr: [CLLocation] = [CLLocation]()
        
            for rs in railStops {
                arr.append(rs.latlon)
            }
            if (railStops.count > 0 && self.selectedStudent.text != "None") {
                locManager.requestWhenInUseAuthorization()
                if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                    stopCoords = closestLocation(locations: arr, closestToLocation: locManager.location!)!
                    course = cardinalDirection(closestToLocation: locManager.location!)!
                
                }
                
                for rs in railStops {
                    if (rs.latlon.distance(from: stopCoords) == 0) {
                        self.currentStop = rs.station
                        break
                    }
                }

        
            self.selectedStudent.text = "None"
       
        let s: String = (self.currentStudent.textLabel?.text)!
        let currentTime: Date = Date()
        let pls: String = previousStop + previousCourse
        //let pts: String = formatter.string(from: self.previousTime!).replacingOccurrences(of: ",", with: "")
        let cls: String = self.currentStop + course
        //let cts: String = formatter.string(from: currentTime).replacingOccurrences(of: ",", with: "")
                
                var cpl:String = ""
                
                if( self.coupled.selectedSegmentIndex == 0)
                {
                    cpl = "uncoupled"
                }
                else if( self.coupled.selectedSegmentIndex == 2)
                {
                    cpl = "coupled"
                }
                else
                {
                    cpl = "none"
                }
            
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
                
    let ttm = formatter.string(from: currentTime.timeIntervalSince(self.previousTime!))!
    
    let fmtr: DateFormatter = DateFormatter()
    fmtr.dateFormat = "HH:mm"
        let str: String = self.todaysDate + "," + s + "," + pls + "," + fmtr.string(from: self.previousTime!) + "," + cls + "," + fmtr.string(from: currentTime) + "," + ttm + "," + cpl + "\n"
        self.csvArray.append(str)
        NSLog(str)
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Could not get location or no student in seat.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            self.show(myAlert, sender: self)        }

        self.coupled.selectedSegmentIndex = 1
    
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
            textField.keyboardType = .numberPad
        })
        myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Train ID"
            textField.keyboardType = .numberPad
        })
        //myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        myAlert.addAction(okAction)
        show(myAlert, sender: self)
        
        
    }
    
    /*

    @IBAction func tapButtonFadeInFadeOut(_ sender: AnyObject) {
        self.showDialog(.fadeInOut)
    }
    
    @IBAction func tapButtonZoomInZoomOut(_ sender: AnyObject) {
        self.showDialog(.zoomInOut)
    }
    
    @IBAction func tapButtonSlideBottomBottom(_ sender: AnyObject) {
        self.showDialog(.slideBottomBottom)
    }
    
    @IBAction func tapButtonSlideBottomTop(_ sender: AnyObject) {
        self.showDialog(.slideBottomTop)
    }
    
    @IBAction func tapButtonSlideLeftLeft(_ sender: AnyObject) {
        self.showDialog(.slideLeftLeft)
    }
    
    @IBAction func tapButtonSlideLeftRight(_ sender: AnyObject) {
        self.showDialog(.slideLeftRight)
    }
    
    @IBAction func tapButtonSlideTopTop(_ sender: AnyObject) {
        self.showDialog(.slideTopTop)
    }
    
    @IBAction func tapButtonSlideTopBottom(_ sender: AnyObject) {
        self.showDialog(.slideTopBottom)
        
    }
    
    @IBAction func tapButtonSlideRightRight(_ sender: AnyObject) {
        self.showDialog(.slideRightRight)
    }
    
    @IBAction func tapButtonSlideRightLeft(_ sender: AnyObject) {
        self.showDialog(.slideRightLeft)
    }

    fileprivate func showDialog(_ animationPattern: LSAnimationPattern) {
        let dialogViewController = rvc
        self.presentDialogViewController(dialogViewController, animationPattern: animationPattern)
    }*/
 
    
    fileprivate func showMap(_ animationPattern: LSAnimationPattern) {
        let mapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        self.presentDialogViewController(mapViewController, animationPattern: animationPattern)
    }
    
    func dismissDialog() {
        self.dismissDialogViewController(LSAnimationPattern.fadeInOut)
    }
    
       
    @IBAction func actionAlert(_ sender: Any) {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        
        
        //self.timestamp.text = formatter.string(from: currentDateTime).replacingOccurrences(of: ",", with: "")
        
        var stopCoords: CLLocation = CLLocation()
        var arr: [CLLocation] = [CLLocation]()
        for rs in railStops {
            arr.append(rs.latlon)
        }
        
        let loc = locManager.location!
        
        if (railStops.count > 0 && self.selectedStudent.text == "None") {
            locManager.requestWhenInUseAuthorization()
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                stopCoords = (self.closestLocation(locations: arr, closestToLocation: loc))!
            }
            for rs in railStops {
                if (rs.latlon.distance(from: stopCoords) == 0) {
                    self.previousStop = rs.station
                    self.previousCourse = cardinalDirection(closestToLocation: loc)!
                    break
                }
            }
        let popup = PopupDialog(title: "Students", message: "Please select student.\nTap outside to cancel.")
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
            show(myAlert, sender: self)}
        } else {
            let myAlert = UIAlertController(title: "Information", message: "Could not get location or student already in seat.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)        }

}
}


