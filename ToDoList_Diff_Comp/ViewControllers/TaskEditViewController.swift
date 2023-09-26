//
//  TaskEditViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/09/22.
//

import UIKit

class TaskEditViewController: UIViewController {
    
    @IBOutlet weak var doneImage: UIImageView!
    @IBOutlet weak var tf: UITextField!
    
    var tvm = TaskViewModel.shared
    
    // task 추가 mode와 수정 mode로 나눈다
    var isCreating: Bool = true
    var taskToEdit: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in return 50 })]
        
        // task 수정 mode일 경우, 전달 받은 기존 task title이 textfield에 입력된 상태
        if !isCreating {
            tf.text = taskToEdit?.title
        }
        
        tf.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if isCreating {
            addTask()
        } else {
            editTask()
        }
        dismiss(animated: true)
    }
    
    private func addTask() {
        guard
            let listId = tvm.list?.id,
            let title = tf.text?.trim()
        else { return }
        
        if title.isEmpty {
            showAlert()
        } else {
            tvm.addTask(tvm.createTask(listId: listId, title))
        }
    }
    
    private func editTask() {
        guard
            var task = taskToEdit,
            let text = tf.text?.trim()
        else { return }
        
        if text.isEmpty {
            showAlert()
        } else {
            task.title = text
            tvm.updateTaskComplete(task)
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "You need to type at least 1 letter.", message: "", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}
