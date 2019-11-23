//
//  ViewController.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/20/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController{
    
    var list = [ToDoData]()
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItem.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    //MARK: -Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // alert will show what the user whant to do
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action =  UIAlertAction(title: "add item", style: .default) { (action) in
            // action is the user pressed the button
            
            let newItem = ToDoData()
            newItem.item = textField.text!
            self.list.append(newItem)
            self.saveData()
            
            //self.defaults.set(self.list.last?.item, forKey: "ToDoItem")
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: -Save and Load new data from/to codable database
    func saveData(){
        
        let encoder = PropertyListEncoder()
        do{
            let data =  try encoder.encode(self.list)
            try data.write(to: self.dataPath!)
        }catch{
            print(error)
        }
    }
    
    func loadData() {
        
        let decoder = PropertyListDecoder()
        do{
            let data = try Data(contentsOf: dataPath!)
            list = try decoder.decode([ToDoData].self, from: data)
        }catch{
            
        }
    }
    
    
    
    //MARK: -TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].item
        let item = list[indexPath.row].selected
        
        cell.accessoryType = item ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        list[indexPath.row].selected = !list[indexPath.row].selected
        saveData()
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

