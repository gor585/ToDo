//
//  ViewController.swift
//  ToDo
//
//  Created by Jaroslav Stupinskyi on 30.03.18.
//  Copyright © 2018 Jaroslav Stupinskyi. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    //Items load as soon as selectedCategory property is set with the value of selected category
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
            cell.backgroundColor = UIColor(hexString: todoItems?[indexPath.row].rowColor ?? "FFFFFF")
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Modifying .done property of Item to the opposite of what it used to be (if true - then false etc)
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
               }
            } catch {
                print("Error updating item: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //Saving new item in selected category
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        newItem.rowColor = UIColor.randomFlat.hexValue()
                        
                        //saving newItem in items list of a selected category (parent relationship)
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item: \(error)")
                }
            }
            
            self.tableView.reloadData()
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
    
    //MARK: - Data Deleting Method
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
    
    
    //MARK: - Data Loading Method
    
    //loadItems method has default value of Item.fetchRequest and predicate in case no value is provided
    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Functionality

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //filtering todoItems for searchBar analogies. If there are any = todoItems is assigned to them
        
//        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

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

