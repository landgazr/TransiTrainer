//
//  ItemViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 8/27/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit

class ListItem: NSObject {
    let itemName: String
    var completed: Bool
    
    init(itemName: String, completed: Bool = false)
    {
        self.itemName = itemName
        self.completed = completed
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

class StudentsViewController: UITableViewController {
    
    static var list: [String] = [String]()
    static var selectedCells: [UITableViewCell] = []
    
    var operators: [Int : String] = [Int : String]()
    
   
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

    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let myBackView: UIView = UIView.init(frame: cell.frame)
        myBackView.backgroundColor = getBackgroundColor(hour: hour)

        
        
        cell.backgroundColor = getBackgroundColor(hour: hour)
        cell.selectedBackgroundView = myBackView

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let date = Date()
        //let calendar = Calendar.current
        
        //let hour = calendar.component(.hour, from: date)
        
        
        //tableView.cellForRow(at: indexPath)?.selectedBackgroundView?.backgroundColor = self.getBackgroundColor(hour: hour)
        
        StudentsViewController.selectedCells.append(tableView.cellForRow(at: indexPath)!)
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        let rowsCount = self.tableView.numberOfRows(inSection: 0)
        for i in 0..<rowsCount  {
            let ip: IndexPath = IndexPath(row: i, section: 0)
            self.tableView.deselectRow(at: ip, animated: false)
            // your custom code (deselecting)
        }
        StudentsViewController.selectedCells.removeAll()
    }
    
    func addCell(s: String)
    {
        var avc: AddingViewController = AddingViewController()
        
        let _: Int = (self.tableView.numberOfRows(inSection: 0))
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is AddingViewController) {
                    avc = viewController as! AddingViewController
                }}}

        if avc.getBadge().isEmpty {
            let myAlert = UIAlertController(title: "Information", message: "Please enter badge #.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        }
        else {
            
            
            
            
            StudentsViewController.list.append(s)
            let indexPath:IndexPath = IndexPath(row:(StudentsViewController.list.count - 1), section:0)
            
            self.tableView.insertRows(at: [indexPath], with: .none)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            
            
            StudentsViewController.selectedCells.removeAll()
        }
                
       
        
    }
    

    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = tableView.cellForRow(at: indexPath)
        if(StudentsViewController.selectedCells.contains(deselectedRow!)){
            let indx = StudentsViewController.selectedCells.index(of: deselectedRow!)
            StudentsViewController.selectedCells.remove(at: indx!)
        }
    }
    
    func writeRoster() {
        
        let file = "roster.csv" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            do {
                // always try to work with URL when accessing Files
                if(FileManager.default.fileExists(atPath: fileURL.path)){
                    try FileManager.default.removeItem(atPath: fileURL.path)
                }
            } catch {/* error handling here */}

            
        var toWrite: String = ""
        toWrite.append("name,badge\n")
        let rowsCount = self.tableView.numberOfRows(inSection: 0)
        for i in 0..<rowsCount  {
            let ip: IndexPath = IndexPath(row: i, section: 0)
            let s = self.tableView.cellForRow(at: ip)?.textLabel?.text
            let studentAndBadge = s?.components(separatedBy: " ")
            toWrite.append((studentAndBadge?[0])! + "," + (studentAndBadge?[1])! + "\n")
        }
            
            do {
                try toWrite.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {/* error handling here */}

            
            
    }
    }
    
    @IBAction func removeSelectedCells(_ sender: Any) {
        
        for r in StudentsViewController.selectedCells {
        let indexPath = IndexPath(row: r.tag, section: 0)
        StudentsViewController.list.remove(at: r.tag)
        self.tableView.deselectRow(at: indexPath, animated: false)
        tableView.deleteRows(at: [indexPath], with: .none)
        }
        
        
        let rowsCount = self.tableView.numberOfRows(inSection: 0)
        for i in 0..<rowsCount  {
            let ip: IndexPath = IndexPath(row: i, section: 0)
            self.tableView.deselectRow(at: ip, animated: false)
            // your custom code (deselecting)
        }
        
        StudentsViewController.selectedCells.removeAll()
        
        self.tableView.reloadData()

       
        
    }
    
    @IBAction func findStudent() {
        var avc: AddingViewController = AddingViewController()
        
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is AddingViewController) {
                    avc = viewController as! AddingViewController
                }}}
        
       
    
    
        var wasNotFound: Bool = true
            let s = avc.getBadge()
        
            for (k, v) in (self.operators) {
                if (Int(s) == k )
                     {
                    
                    
                    let op: String = v
                    let bd: Int = k
                    let myAlert = UIAlertController(title: "Information", message: op  + " " + String(bd), preferredStyle: .alert);
                        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
                            self.addCell(s: op + " " + String(bd))
                            }))

                    myAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
                    show(myAlert, sender: self)
                    wasNotFound = false
                        
                    break

                    
                }
        }
        if( wasNotFound)
               {
                var str: String = ""
                var firstName: Bool = true
                var first: String = ""
                let myAlert = UIAlertController(title: "Information", message: "Student not found. Enter name to add.", preferredStyle: .alert);
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    for utf in myAlert.textFields! {
                        if( firstName ) {
                        first = "/" + utf.text! + " "
                            firstName = false
                        } else {
                            str = utf.text! + first
                        }
                    }
                    self.addCell(s: str + s)
                })
                myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                    textField.placeholder = "Student first name"
                })
                myAlert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
                    textField.placeholder = "Student last name"
                })
                myAlert.addAction(okAction)
                myAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil));
                show(myAlert, sender: self)
                }
            
            

        }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let fileURL2 = Bundle.main.url(forResource: "operators", withExtension: "csv") {
            
            do {
                // always try to work with URL when accessing Files
                
                let operatorsStr = try String(contentsOf: fileURL2)
                let parsedCSV: [[String]] = operatorsStr.components(separatedBy: .newlines).map{ $0.components(separatedBy: ",") }
                
                for row in parsedCSV {
                    if( row.count > 1) {
                        self.operators[Int(row[1])!] = row[0] }
                }
                
                
            } catch {/* error handling here */}
        }
            
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        
        self.tableView.backgroundColor = getBackgroundColor(hour: hour)
        
        let file = "roster.csv" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            do {
                  // always try to work with URL when accessing Files
                if(FileManager.default.fileExists(atPath: fileURL.path)){
                    let roster = try String(contentsOf: fileURL, encoding: .utf8)
                    let arr: [String] = roster.components(separatedBy: "\n")
                    
                    for a in arr {
                        if( !a.isEmpty) {
                            let indexPath:IndexPath = IndexPath(row:(StudentsViewController.list.count - 1), section:0)
                            
                            if( indexPath.item > 0) {
                        StudentsViewController.list.append(a.replacingOccurrences(of: ",", with: " "))
                        //let indexPath:IndexPath = IndexPath(row:(StudentsViewController.list.count - 1), section:0)
                        self.tableView.insertRows(at: [indexPath], with: .none)
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        }

                    }
                    
                    
                }
            } catch {/* error handling here */}
            
                    }}
    
        

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsViewController.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.tag = indexPath.row
        
        cell.textLabel?.text = StudentsViewController.list[indexPath.item]
        
        return cell
    }
    

    func getSelectedStudents() -> [UITableViewCell]{
        
        return StudentsViewController.selectedCells

    //for ip: UITableViewCell in self.selectedCells {
    //        NSLog((ip.textLabel?.text)!)
    //}
    }
    
    
}

