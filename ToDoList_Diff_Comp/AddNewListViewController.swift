//
//  AddNewListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class AddNewListViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!

    var vm = TaskViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
    }
    
    // modal dismiss 직전 main에 noti
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("modalDismissed"), object: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard var newListName = textField.text?.trim() else { return }
        if newListName.isEmpty {
            newListName = "Untitled list"
        }
        vm.addList(vm.createList(newListName))

        dismiss(animated: true)
    }
}
