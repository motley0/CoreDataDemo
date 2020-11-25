//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 23.11.2020.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "Add New Task", andMessage: "What do you want to do?")
    }
    
    private func fetchData() {
        tasks = StorageManager.shared.fetchTasks()
        tableView.reloadData()
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showEditAlert(title: String,
                               message: String,
                               task: Task,
                               indexPath : IndexPath) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text,
                  !taskName.isEmpty else { return }
            
            task.name = taskName
            StorageManager.shared.saveContext()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField() { textField in
            textField.text = task.name
        }
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        guard let task = StorageManager.shared.createTask(taskName: taskName) else {
            return
        }
        tasks.append(task)
        
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }

}

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                 for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") {_, _, _ in
            StorageManager.shared.deleteTask(task: task)
            self.tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Edit") {_, _, complete in
            self.showEditAlert(title: "Edit Task",
                               message: "Just do it!",
                               task: task,
                               indexPath: indexPath)
            complete(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

