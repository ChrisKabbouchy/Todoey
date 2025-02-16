//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/24/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var listCategory : Results<CategoryData>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.rowHeight = 80.0
        
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        // alert will show what the user whant to do
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action =  UIAlertAction(title: "Add Category", style: .default) { (action) in
            // action is the user pressed the button
            
            let newItem = CategoryData()
            newItem.name = textField.text!
        
            self.saveData(category: newItem)
            
            //self.defaults.set(self.list.last?.item, forKey: "ToDoItem")
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: -Data Manipulation
    
    func saveData(category: CategoryData){
        
        do{
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("error while saving context\(error)")
        }
    }
    
    func loadData() {
        
        listCategory = realm.objects(CategoryData.self)
        
        tableView.reloadData()
    }
    
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCategory?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell" , for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = listCategory?[indexPath.row].name ?? "No Data"
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        let indexPath = tableView.indexPathForSelectedRow!
        destinationVC.parentCategory = listCategory?[indexPath.row]
        
    }
}


//MARK: -Swipe Kit View delegate

extension CategoryTableViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            do{
                try self.realm.write {
                    //let newItem = self.listCategory![]
                    self.realm.delete(self.listCategory![indexPath.row])
                }
            }catch{
                print(error)
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash")

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

extension CategoryTableViewController : UISearchBarDelegate{

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        listCategory = listCategory?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
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

