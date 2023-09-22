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
    
    var vm = TaskViewModel.shared
    
    var index: Int?
    var isCreating: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in return 50 })]
        
        tf.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if isCreating {
            addTask()
        } else {
            
        }
        // TODO: 입력값이 없을 때 alert 표시
        // TODO: task 추가/수정 되자마자 view reload
        dismiss(animated: true)
    }
    
    private func addTask() {
        guard
            let index = index,
            let title = tf.text?.trim()
        else { return }
        
        vm.addTask(listId: vm.lists[index].id, vm.createTask(listId: vm.lists[index].id, title))
    }
    
    private func editTask() {
        
    }
}
