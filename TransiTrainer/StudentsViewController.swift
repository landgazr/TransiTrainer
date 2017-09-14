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
    
    let list = ["studentA","studentB","studentC","studentD","studentE"]
    var selectedCells: [UITableViewCell] = []
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCells.append(tableView.cellForRow(at: indexPath)!)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedRow = tableView.cellForRow(at: indexPath)
        if(selectedCells.contains(deselectedRow!)){
            let indx = selectedCells.index(of: deselectedRow!)
            selectedCells.remove(at: indx!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.item]
        
        return cell
    }
    

    func getSelectedStudents() -> [UITableViewCell]{
        
        return self.selectedCells

    //for ip: UITableViewCell in self.selectedCells {
    //        NSLog((ip.textLabel?.text)!)
    //}
    }
    
    
}

