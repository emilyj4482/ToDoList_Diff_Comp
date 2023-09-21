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
        vm.addList(vm.createList(examListName(newListName)))
        
        print(vm.lists)
        
        dismiss(animated: true)
        
        // Done button에 의하여 modal dismiss 시 main에 noti
        NotificationCenter.default.post(name: NSNotification.Name("newListAdded"), object: nil)
    }
    
    // list name 중복검사
    func examListName(_ text: String) -> String {
        let list = vm.lists.map { list in
            list.name
        }
        
        var count = 1
        var listName = text
        while list.contains(listName) {
            listName = "\(text) (\(count))"
            count += 1
        }
        
        return listName
    }
}
