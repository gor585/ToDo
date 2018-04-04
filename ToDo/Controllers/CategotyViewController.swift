//
//  CategotyViewController.swift
//  ToDo
//
//  Created by Jaroslav Stupinskyi on 04.04.18.
//  Copyright © 2018 Jaroslav Stupinskyi. All rights reserved.
//

import UIKit
import CoreData

class CategotyViewController: UITableViewController {
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadCategories()
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        //Identifying selected category:
        if let indexPath = tableView.indexPathForSelectedRow {
            //Setting selectedCategory property to selected category
            destinationVC.selectedCategory = categories[indexPath.row]
            
        }
        
    }
    
    
    //MARK: - Data Saving Method
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Data Loading Method
    
    func loadCategories() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            self.saveCategories()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
