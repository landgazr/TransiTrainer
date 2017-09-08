//
//  FirstViewController.swift
//  TransiTrainer
//
//  Created by Stone, Gabe on 8/27/17.
//  Copyright © 2017 Tri-Met. All rights reserved.
//

import UIKit


class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
        
        try SimpleKML.init(contentsOfFile: "/path/to/file.kml")
        } catch {
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that nevertheless can be recreated.
        
    }
    

    @IBAction func actionAlert(_ sender: Any) {
        let myAlert = UIAlertController(title: "Alert", message: "This is an alert.", preferredStyle: .alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        show(myAlert, sender: self)
    }
   
}

