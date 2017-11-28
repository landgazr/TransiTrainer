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
    
    var delegate: MainlineViewController?
    var studentCell: UITableViewCell = UITableViewCell()
    var inStation: RailStation = RailStation()
    var outStation: RailStation = RailStation()
    var mvc: MainlineViewController = MainlineViewController()
    var svc: StudentsViewController = StudentsViewController()
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        self.delegate?.dismissDialog()
    }
    
    @IBAction func submitButton(_ sender: AnyObject) {
        
        if (MainlineViewController.stationsVisited.count > 0 && studentPicker.selectedRow(inComponent: 0) > 0) {
            mvc.reconcile(student: studentCell, inLocation: inStation, outLocation: outStation)
            self.delegate?.dismissDialog()
        }
        else {
            let myAlert = UIAlertController(title: "Information", message: "Please select values for all three items.", preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            show(myAlert, sender: self)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == studentPicker {
            if( row == 0 ){
                //
            } else {
                self.studentCell = svc.getSelectedStudents()[row - 1]
            }
        } else if pickerView == inPicker{
          
            if( MainlineViewController.stationsVisited.count > row) {
                let firstKey = Array(MainlineViewController.stationsVisited.keys)[row]
                self.inStation = MainlineViewController.stationsVisited[firstKey]!
            }
            
        }
        else
        {
           if( MainlineViewController.stationsVisited.count > row) {
                let firstKey = Array(MainlineViewController.stationsVisited.keys)[row]
                self.outStation = MainlineViewController.stationsVisited[firstKey]!
            }
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == studentPicker {
            return svc.getSelectedStudents().count + 1
        }
        else
        {
            return (MainlineViewController.stationsVisited.count)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView == studentPicker {
           return row == 0 ? "" : svc.getSelectedStudents()[row - 1].textLabel?.text
        } else {
            
            if( MainlineViewController.stationsVisited.count > row) {
                let firstKey = Array(MainlineViewController.stationsVisited.keys)[row]
                return MainlineViewController.stationsVisited[firstKey]?.station?.station
            }
            else
            {
                return ""
            }
            
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
