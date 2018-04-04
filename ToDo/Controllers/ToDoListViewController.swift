//
//  ViewController.swift
//  ToDo
//
//  Created by Jaroslav Stupinskyi on 30.03.18.
//  Copyright © 2018 Jaroslav Stupinskyi. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemAray = [Item]()
    
    //Items load as soon as selectedCategory property is set with the value of selected category
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemAray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Modifying .done property of Item to the opposite of what it used to be (if true - then false etc)
        
        itemAray[indexPath.row].done = !itemAray[indexPath.row].done
        
//        context.delete(itemAray[indexPath.row])
//        itemAray.remove(at: indexPath.row)
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //Action when the button is clicked
            
            //Creating new Item object and appending it to the itemArray
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            //Specifying parentCategory of new item
            newItem.parentCategory = self.selectedCategory
            
            self.itemAray.append(newItem)
            
            self.saveItems()
        }
        
        //Adding text field to the alert
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //Adding action to the alert
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Saving Method
    
    func saveItems() {
        
        do  {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: - Data Loading Method
    
    //loadItems method has default value of Item.fetchRequest and predicate in case no value is provided
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemAray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Functionality

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //Sorting results (in array) ascending by title:
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //Getting back to the original list of items (if search text == 0)
        
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                //Deselecting search bar & dissmissing keyboard:
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

