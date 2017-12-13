//
//  RetroViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 11/26/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit

class RetroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    @IBOutlet weak var studentPicker: UIPickerView!
    @IBOutlet weak var inPicker: UIPickerView!
    @IBOutlet weak var outPicker: UIPickerView!
    @IBOutlet weak var coupled: UISegmentedControl!
    var stdArr: [String] = []
    var inArr: [String] = []
    var outArr: [String] = []
    
    //var delegate: MainlineViewController?
    var studentCell: String!
    var inStation: RailStation!
    var outStation: RailStation!
    var mvc: MainlineViewController = MainlineViewController()
    var svc: StudentsViewController = StudentsViewController()
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        mvc.dismissDialog()
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        
        if (mvc.stationsVisited.count > 0) {
            mvc.reconcile(student: studentCell, inLocation: inStation, outLocation: outStation, couple: self.coupled.selectedSegmentIndex)
            mvc.dismissDialog()
        }
        else {
            let myAlert = UIAlertController(title: "Information", message: "Please select values for all three items.", preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            show(myAlert, sender: self)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == studentPicker {
           
            if (svc.getSelectedStudents().count > 0)
            {
                self.studentCell = stdArr[row]
            }
        } else if pickerView == inPicker{
          
            if( mvc.stationsVisited.count > 0) {
                let firstKey = inArr[row]
                self.inStation = mvc.stationsVisited[firstKey]!
            }
            
        }
        else
        {
           if( mvc.stationsVisited.count > 0) {
                let firstKey = outArr[row]
                self.outStation = mvc.stationsVisited[firstKey]!
            }
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == studentPicker {
            return stdArr.count
        }
        else if pickerView == inPicker
        {
            return inArr.count
        }
        else
        {
            return outArr.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView == studentPicker {
            
            if( stdArr.count == 0 )
            {
                return ""
            }
            else
            {
                return self.stdArr[row]
            }
        }
            
         else if pickerView == inPicker {
            
            if( inArr.count == 0 )
            {
                return ""
            }
            else
            {
                return inArr[row]
            }
            
        }
        else
        {
            if( outArr.count == 0 )
            {
                return ""
            }
            else
            {
                return outArr[row]
            }
        }
    }
            

    
    override func viewWillAppear(_ animated: Bool) {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is StudentsViewController) {
                    svc = viewController as! StudentsViewController
                }
                else if (viewController is MainlineViewController) {
                    mvc = viewController as! MainlineViewController
                }
            }
            
        }
        self.inPicker.delegate = self
        self.outPicker.delegate = self
        self.studentPicker.delegate = self
        self.inPicker.dataSource = self
        self.outPicker.dataSource = self
        self.studentPicker.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
