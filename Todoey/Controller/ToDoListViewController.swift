//
//  ViewController.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/20/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{
    
    var parentCategory : CategoryData?{
        didSet{
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var list = [ToDoData]()
    let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    //MARK: -Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // alert will show what the user whant to do
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action =  UIAlertAction(title: "add item", style: .default) { (action) in
            // action is the user pressed the button
            
            let newItem = ToDoData(context: self.context)
            newItem.item = textField.text!
            newItem.selected = false
            newItem.parentCategory = self.parentCategory
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
    
    
    
    //MARK: -Save and Load new data from/to core data
    func saveData(){
        
        do{
            try context.save()
        }catch{ 
            print("error while saving context\(error)")
        }
    }
    
    func loadData(with request : NSFetchRequest<ToDoData> = ToDoData.fetchRequest(), predicate : NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", parentCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do {
            list = try context.fetch(request)
        } catch  {
            print("error while fetching contex\(error)")
        }
        
        tableView.reloadData()
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

//MARK: -SearchBar functions

extension ToDoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<ToDoData> = ToDoData.fetchRequest()
        let predicate = NSPredicate(format: "item CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "item", ascending: true)]
        loadData(with: request,predicate: predicate)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

