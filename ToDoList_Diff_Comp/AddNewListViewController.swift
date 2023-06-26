//
//  AddNewListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class AddNewListViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
