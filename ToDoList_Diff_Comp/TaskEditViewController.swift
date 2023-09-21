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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in return 50 })]
        
        tf.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        print(tf.text ?? "")
        
        dismiss(animated: true)
    }
}
