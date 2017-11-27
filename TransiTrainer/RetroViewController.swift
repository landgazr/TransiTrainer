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
    
    var studentCell: UITableViewCell = UITableViewCell()
    var inStation: RailStation = RailStation()
    var outStation: RailStation = RailStation()
    var mvc: MainlineViewController = MainlineViewController()
    var svc: StudentsViewController = StudentsViewController()
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == studentPicker {
            if( row == 0 ){
                //
            } else {
                self.studentCell = svc.getSelectedStudents()[row - 1]
            }
        } else if pickerView == inPicker{
            if( row == 0 ){
                //
            } else {
                self.inStation = (MainlineViewController.stationsVisited?.list[row - 1])!
            }
        }
        else
        {
            if( row == 0 ){
                //
            } else {
                self.outStation = (MainlineViewController.stationsVisited?.list[row - 1])!
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
            return (MainlineViewController.stationsVisited?.count())!
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView == studentPicker {
           return row == 0 ? "" : svc.getSelectedStudents()[row - 1].description
        } else if pickerView == inPicker{
            return row == 0 ? "" : MainlineViewController.stationsVisited?.list[row - 1].station?.station
        }
        else
        {
           return row == 0 ? "" : MainlineViewController.stationsVisited?.list[row - 1].station?.station
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
