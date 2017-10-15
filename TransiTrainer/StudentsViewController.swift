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

class StudentsViewController: UITableViewController {
    
    static var list: [String] = [String]()
    static var selectedCells: [UITableViewCell] = []
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    @IBAction func addCell()
    {
        var avc: AddingViewController = AddingViewController()
        
        let _: Int = (self.tableView.numberOfRows(inSection: 0))
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is AddingViewController) {
                    avc = viewController as! AddingViewController
                }}}

        if avc.getNameAndBadge().isEmpty {
            let myAlert = UIAlertController(title: "Information", message: "Please enter both name and badge.", preferredStyle: .alert);
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
            show(myAlert, sender: self)
        }
        else {
            
            
            let s = avc.getNameAndBadge()
            
            StudentsViewController.list.append(s)
            let indexPath:IndexPath = IndexPath(row:(StudentsViewController.list.count - 1), section:0)
            
            self.tableView.insertRows(at: [indexPath], with: .none)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        
       self.tableView.reloadData()
        
        let rowsCount = self.tableView.numberOfRows(inSection: 0)
        for i in 0..<rowsCount  {
            let ip: IndexPath = IndexPath(row: i, section: 0)
            self.tableView.deselectRow(at: ip, animated: false)
            // your custom code (deselecting)
        }
        
        StudentsViewController.selectedCells.removeAll()

        
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        
        let file = "roster.csv" //this is the file. we will write to and read from it
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            do {
                  // always try to work with URL when accessing Files
                if(FileManager.default.fileExists(atPath: fileURL.path)){
                    let roster = try String(contentsOf: fileURL, encoding: .utf8)
                    let arr: [String] = roster.components(separatedBy: "\n")
                    
                    for a in arr {
                        StudentsViewController.list.append(a.replacingOccurrences(of: ",", with: " "))
                    }
                                   }
            } catch {/* error handling here */}
            
        
        
    }
    }
    
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

