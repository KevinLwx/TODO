//
//  ViewController.swift
//  TODO
//
//  Created by 刘铭 on 2018/2/23.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  var itemArray = [Item]()
//   let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist")
    var selectedCategory: Category? {
        didSet{
            loadItem()
        }
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
   
    
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//     let request: NSFetchRequest<Item> = Item.fetchRequest()
//    loadItem()
    
  }
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }else {
            request.predicate = categoryPredicate

        }
        
        do {
             itemArray = try context.fetch(request)
        } catch  {
            print("从context中获取数据失败：\(error)")
        }
        tableView.reloadData()
        
    }
  
  //MARK: - Table View DataSource methods
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // print("更新第：\(indexPath.row)行")
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
    cell.textLabel?.text = itemArray[indexPath.row].title
    
    let item = itemArray[indexPath.row]
    
    cell.accessoryType = item.done == true ? .checkmark : .none
    
//    if item.done == false {
//      cell.accessoryType = .none
//    }else {
//      cell.accessoryType = .checkmark
//    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return itemArray.count
  }
  
  //MARK: - Table View Delegate methods
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    itemArray[indexPath.row].done = !itemArray[indexPath.row].done
    
//    guard let title = itemArray[indexPath.row].title else { return  }
//    itemArray[indexPath.row].setValue(title + " - (已完成)", forKey: "title")
    
//    context.delete(itemArray[indexPath.row])
//    itemArray.remove(at: indexPath.row)
    
    saveItems()
    tableView.beginUpdates()
    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    tableView.endUpdates()
    
    tableView.deselectRow(at: indexPath, animated: true)

  }
    
    func saveItems() {
        do{
            try context.save()
        }catch{
            print("解码错误")
        }
        tableView.reloadData()
        
    }
    
  //MARK: - Add New Items
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    
    let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "添加项目", style: .default) { (action) in
      // 当用户点击添加项目按钮以后要执行的代码
        
        let newItem = Item(context: self.context)
        newItem.title = textField.text!
        newItem.done = false
        newItem.parentCategory = self.selectedCategory
        self.itemArray.append(newItem)
        self.saveItems()
       
        //只可以存基础类型的int double float bool array dictionary 。复杂对象不行
        //        self.defaults.set(self.itemArray, forKey: "ToDoListArray")
     
      self.tableView.reloadData()
    }
    
    alert.addTextField { (alertTextField) in
      alertTextField.placeholder = "创建一个新项目..."
      textField = alertTextField
    }
    
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }

}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        request.predicate = predicate
        let sortDescriptors = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        
        loadItem(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }
        }
    }
}

