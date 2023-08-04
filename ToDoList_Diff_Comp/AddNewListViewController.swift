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
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard var newListName = textField.text?.trim() else { return }
        if newListName.isEmpty {
            newListName = "Untitled list"
        }
        vm.addList(vm.createList(newListName))
        
        print(vm.lists)
        
        dismiss(animated: true)
        
        // Done button에 의하여 modal dismiss 시 main에 noti
        NotificationCenter.default.post(name: NSNotification.Name("newListAdded"), object: nil)
    }
}
