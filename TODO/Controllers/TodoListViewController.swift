//
//  ViewController.swift
//  TODO
//
//  Created by 刘铭 on 2018/2/23.
//  Copyright © 2018年 刘铭. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
  
//  let defaults = UserDefaults.standard
  
  var itemArray = [Item]()
   let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist")
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
   
    
    print(dataFilePath!)
    
    loadItem()
    
  }
    func loadItem() {
        if let data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                itemArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("解码错误")
            }
            
        }
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
    saveItems()
    tableView.deselectRow(at: indexPath, animated: true)
    
//    if itemArray[indexPath.row].done == false {
//      itemArray[indexPath.row].done = true
//    }else {
//      itemArray[indexPath.row].done = false
//    }
    
//    tableView.beginUpdates()
//    tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//    tableView.endUpdates()
//
//    tableView.deselectRow(at: indexPath, animated: true)
  }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
            
        }catch {
            print("编码错误: \(error)")
        }
    }
    
  //MARK: - Add New Items
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    
    let alert = UIAlertController(title: "添加一个新的ToDo项目", message: "", preferredStyle: .alert)
    
    let action = UIAlertAction(title: "添加项目", style: .default) { (action) in
      // 当用户点击添加项目按钮以后要执行的代码
      
      let newItem = Item()
      newItem.title = textField.text!
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

