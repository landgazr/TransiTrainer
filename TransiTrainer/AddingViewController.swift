//
//  AddingViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 10/15/17.
//  Copyright © 2017 Gabe Stone. All rights reserved.
//

import UIKit

class AddingViewController: UIViewController {

    var svc: StudentsViewController = StudentsViewController()
    var ss = [UITableViewCell]()

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var badge: UITextField!
    
    var numberToolbar: UIToolbar = UIToolbar()
    
    @objc func done () {
    badge.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberToolbar.items=[
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(AddingViewController.done))
            
        ]
        
        numberToolbar.sizeToFit()
        
        badge.inputAccessoryView = numberToolbar
        
        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is StudentsViewController) {
                    svc = viewController as! StudentsViewController
                    ss = svc.getSelectedStudents()
                }
            }
            
        }
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)

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
    

   
    func getBadge () -> String {
        
        if((badge.text?.isEmpty)!) {
           return ""
        }
        else {
        let str = badge.text!
            return str
        }
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
