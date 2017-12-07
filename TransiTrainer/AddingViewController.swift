//
//  AddingViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 10/15/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit

class AddingViewController: UIViewController {

    var svc: StudentsViewController = StudentsViewController()
    var ss = [UITableViewCell]()

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var badge: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = UIApplication.shared.keyWindow?.rootViewController?.childViewControllers {
            for viewController in viewControllers {
                if (viewController is StudentsViewController) {
                    svc = viewController as! StudentsViewController
                    ss = svc.getSelectedStudents()
                }
            }
            
        }
    }
   
    func getNameAndBadge () -> String {
        
        if( (name.text?.isEmpty)! || (badge.text?.isEmpty)!) {
           return ""
        }
        else {
        let str = name.text! + " " + badge.text!
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
