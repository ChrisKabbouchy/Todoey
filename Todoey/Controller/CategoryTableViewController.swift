//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Christian Kabouchy on 11/24/19.
//  Copyright © 2019 Christian Kabouchy. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var listCategory = [CategoryData]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        // alert will show what the user whant to do
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        let action =  UIAlertAction(title: "Add Category", style: .default) { (action) in
            // action is the user pressed the button
            
            let newItem = CategoryData(context: self.context)
            newItem.name = textField.text!
            
            self.listCategory.append(newItem)
            self.saveData()
            
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
    
    func saveData(){
        
        do{
            try context.save()
        }catch{
            print("error while saving context\(error)")
        }
    }
    
    func loadData(with request : NSFetchRequest<CategoryData> = CategoryData.fetchRequest()) {
        
        do {
            listCategory = try context.fetch(request)
        } catch  {
            print("error while fetching contex\(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listCategory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell" , for: indexPath)
        cell.textLabel?.text = listCategory[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        let indexPath = tableView.indexPathForSelectedRow!
        destinationVC.parentCategory = listCategory[indexPath.row]
        
    }
}



//MARK: -SearchBar functions

extension CategoryTableViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        loadData(with: request)
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

