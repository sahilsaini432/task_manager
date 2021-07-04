//
//  ViewController.swift
//  Task
//
//  Created by Sahil Saini on 2021-05-03.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableview: UITableView!
    
    var tasks = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tasks"
        
        tableview.delegate = self
        tableview.dataSource = self
        
        //Setup
        if !UserDefaults().bool(forKey: "setup") {
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(0, forKey: "count")
        } else {
            self.updateTasks()
        }
        // Get all current saved tasks
    }
    
    func updateTasks() {
        
        tasks.removeAll()
        
        guard let count = UserDefaults().value(forKey: "count") as? Int else {
            return
        }
        for x in 0...count {
            if let task = UserDefaults().value(forKey: "task_\(x+1)") as? String{
                tasks.append(task)
            }
        }
        tableview.reloadData()
    }
    
    @IBAction func didTapAdd() {
        let vc = storyboard?.instantiateViewController(identifier: "entry") as! EntryViewController
        vc.title = "New Task"
        vc.update = {
            DispatchQueue.main.async {
                self.updateTasks()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cell = self.tableview.cellForRow(at: indexPath)

        let ac = UIAlertController(title: nil, message: "Update Task", preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].text = cell?.textLabel?.text

        let submitAction = UIAlertAction(title: "Update", style: .default) { [unowned ac] _ in
            guard let newName  = ac.textFields![0].text else {
                return
            }
            
            //update the cell value
            guard let libraryCell = self.tableview.cellForRow(at: indexPath) else {
                fatalError("Cell must be valid")
            }
            
            guard let count = UserDefaults().value(forKey: "count") as? Int else {
                return
            }
            
            for x in 0...count {
                if let task = UserDefaults().value(forKey: "task_\(x+1)") as? String{
                    if task == libraryCell.textLabel?.text {
                        UserDefaults().setValue(newName, forKey: "task_\(x+1)")
                        libraryCell.textLabel!.text = newName
                        
                        self.updateTasks()
                        return
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            //do nothing
            return
        }

        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        self.present(ac, animated: true)

    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = tasks[indexPath.row]
        
        return cell
    }
    
}
