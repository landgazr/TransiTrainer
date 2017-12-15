//
//  RetroViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 11/26/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit

class RetroViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    

    @IBOutlet weak var studentPicker: UIPickerView!
    @IBOutlet weak var inBar: UISearchBar!
    @IBOutlet weak var inTable: UITableView!
    
    @IBOutlet weak var outBar: UISearchBar!
    @IBOutlet weak var outTable: UITableView!
    @IBOutlet weak var coupled: UISegmentedControl!
    @IBOutlet weak var submitButton: UIButton!
    
    var inFilter:[String] = []
    var outFilter:[String] = []
    
    var stdArr: [String] = []
    var inArr: [String] = []
    var outArr: [String] = []
    
    //var delegate: MainlineViewController?
    var studentCell: String!
    var inStation: RailStation!
    var outStation: RailStation!
    var mvc: MainlineViewController = MainlineViewController()
    var svc: StudentsViewController = StudentsViewController()
    var isSearch:Bool = false
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        if (svc.getSelectedStudents().count > 0) {
            self.studentCell = stdArr[row]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stdArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if( stdArr.count == 0) {
            return ""
        }
        else
        {
            return self.stdArr[row]
        }
    }
    
    @IBAction func submitDisable(_ sender: UIButton) {
        
        sender.alpha = 0.4
        sender.isEnabled = false
        
    }
    
   
    @IBAction func submitButton(_ sender: UIButton) {
        
        if (mvc.stationsVisited.count > 0) {
            mvc.reconcile(student: studentCell, inLocation: inStation, outLocation: outStation, couple: self.coupled.selectedSegmentIndex)
           
            
        }
        else {
            let myAlert = UIAlertController(title: "Information", message: "Please select values for all three items.", preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            show(myAlert, sender: self)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        if( tableView == inTable ) {
            if( mvc.stationsVisited.count > 0) {
                let firstKey = inArr[didSelectRowAt.row]
                self.inStation = mvc.stationsVisited[firstKey]!
            }
        }
        else {
            if( mvc.stationsVisited.count > 0) {
                let firstKey = outArr[didSelectRowAt.row]
                self.outStation = mvc.stationsVisited[firstKey]!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearch) {
            if( tableView == inTable) {
                return inFilter.count }
            else {
                return outFilter.count }
        }
        else {
            if( tableView == inTable) {
                return inArr.count }
            else {
                return outArr.count }
        }
    }
    
    
    
    func configureCell(tv: UITableView, cell: UITableViewCell, forRowAtIndexPath: NSIndexPath) {
        if(isSearch){
            if( tv == inTable) {
                cell.textLabel?.text = inFilter[forRowAtIndexPath.row] }
            else {
                cell.textLabel?.text = outFilter[forRowAtIndexPath.row] }
            
            
        } else {
            if( tv == inTable) {
                cell.textLabel?.text = inArr[forRowAtIndexPath.row] }
            else {
                cell.textLabel?.text = outArr[forRowAtIndexPath.row] }
        }
    }
    
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if( tableView == inTable)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inCell1", for: indexPath)
            configureCell(tv: tableView, cell: cell, forRowAtIndexPath: indexPath as NSIndexPath)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "outCell1", for: indexPath)
            configureCell(tv: tableView, cell: cell, forRowAtIndexPath: indexPath as NSIndexPath)
            return cell
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.characters.count == 0 {
            isSearch = false;
            self.inTable.reloadData()
            self.outTable.reloadData()
        } else {
            
            if( searchBar == inBar ) {
                inFilter = inArr.filter({ $0.contains(searchText) })
            }
            else {
                outFilter = outArr.filter({ $0.contains(searchText) })
            }
            
            if(inFilter.count == 0 && outFilter.count == 0){
                isSearch = false;
            } else {
                isSearch = true;
            }
            
            self.inTable.reloadData()
            self.outTable.reloadData()
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inBar.returnKeyType = .done
        outBar.returnKeyType = .done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.stdArr = []
        self.inArr = []
        self.outArr = []
        let fmtr = DateFormatter()
        fmtr.dateFormat = "HH:mm"
        
        for stn in mvc.stationsVisited {
            
            let key = (stn.station?.station)! + "@" + fmtr.string(from: stn.arrivalTime!)
            self.inArr.append(key)
            self.outArr.append(key)
            
        }
        for std in svc.getSelectedStudents() {
            self.stdArr.append((std.textLabel?.text)!)
        }
        if stdArr.count > 0 {
            self.studentCell = stdArr[0]
        }
        studentPicker.reloadAllComponents()
        submitButton.isEnabled = true
        submitButton.isUserInteractionEnabled = true
        submitButton.setTitle("Submitted", for: UIControlState.disabled)
        submitButton.alpha = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        

        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is StudentsViewController) {
                    svc = viewController as! StudentsViewController
                }
                else if (viewController is MainlineViewController) {
                    mvc = viewController as! MainlineViewController
                    mvc.modalPresentationStyle = .none
                }
            }
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
