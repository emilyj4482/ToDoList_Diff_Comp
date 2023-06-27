//
//  ToDoListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class ToDoListViewController: UIViewController {

    var vm = TaskViewModel.shared
    
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = index {
            print(vm.lists[index])
        }
        
        barButtons()
        
    }
    
    private func barButtons() {
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        print("add btn tapped")
    }
    
}
