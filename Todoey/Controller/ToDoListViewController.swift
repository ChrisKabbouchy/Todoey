//
//  ViewController.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/20/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ToDoListViewController: UITableViewController{
    
    var parentCategory : CategoryData?{
        didSet{
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var list : Results<ToDoData>?
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.rowHeight = 80.0
        // Do any additional setup after loading the view.
    }
    
    
    
    
    //MARK: -Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // alert will show what the user whant to do
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action =  UIAlertAction(title: "add item", style: .default) { (action) in
            // action is the user pressed the button
            if let currentCategory = self.parentCategory{
                
                do {
                    try self.realm.write {
                        let newItem = ToDoData()
                        newItem.item = textField.text!
                        newItem.selected = false
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch  {
                    print(error)
                }
                
            }
            
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
    func loadData() {
        
        list = parentCategory?.items.sorted(byKeyPath: "item", ascending: true )
        
        tableView.reloadData()
    }
    
    
    
    //MARK: -TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        
        cell.textLabel?.text = list?[indexPath.row].item ?? "No Data"
        cell.delegate = self
        
        if let item = list?[indexPath.row].selected{
            cell.accessoryType = item ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = list?[indexPath.row] {
            do {
                try realm.write {
                    item.selected = !item.selected
                    //realm.delete(item)
                }
            } catch  {
                print(error)
            }
        }

        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: -Swipe Kit View delegate

extension ToDoListViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            do{
                try self.realm.write {
                    //let newItem = self.listCategory![]
                    self.realm.delete(self.list![indexPath.row])
                }
            }catch{ 
                print(error)
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash.circle.fill")

        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}

//MARK: -SearchBar functions

extension ToDoListViewController : UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        list = list?.filter("item CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
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

