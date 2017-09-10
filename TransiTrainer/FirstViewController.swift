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
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that nevertheless can be recreated.
        
    }
    
    func getKML(fp: String) -> SimpleKML {
       
        let u: URL = URL.init(fileURLWithPath: fp)
       
       
        do {
            
            return SimpleKML.init(contentsOf: u)
            NSLog("OK")
            
        } catch {
            NSLog("error")
        }

        return SimpleKML.init()
    }
    
   
    @IBAction func actionAlert(_ sender: Any) {
        let myAlert = UIAlertController(title: "Alert", message: "This is an alert.", preferredStyle: .alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        show(myAlert, sender: self)
        let filepath = Bundle.main.path(forResource: "tm_rail_stops", ofType: "kml")
        var myKML: SimpleKML = getKML(fp: filepath!)
        NSLog("done")
    }}

