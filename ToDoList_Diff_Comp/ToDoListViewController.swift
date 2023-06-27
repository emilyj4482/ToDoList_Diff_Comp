//
//  ToDoListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class ToDoListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tfView: UIView!
    @IBOutlet weak var addbutton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tfViewBottom: NSLayoutConstraint!
    
    var vm = TaskViewModel.shared
    
    var index: Int?
    
    // Add a Task 버튼 tap 시 여러가지 기능 on / off
    var addTaskMode: Bool = false {
        didSet {
            modeOnOff()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let index = index else { return }
        print(vm.lists[index])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(rightButtonTapped))
        
        // important list일 때는 task 추가 및 listname 수정 기능 잠금
        if index == 0 {
            addbutton.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
        }
    }
    
    @objc func rightButtonTapped() {
        print("right btn tapped")
        // test code
        addTaskMode = false
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        print("add btn tapped")
        // test code
        addTaskMode = true
    }
    
}

extension ToDoListViewController {
    // Add a Task mode on / off 시 동작 구분
    func modeOnOff() {
        if addTaskMode == true {
            navigationItem.rightBarButtonItem?.title = "Done"
            addbutton.isHidden = true
            tfView.isHidden = false
            textField.becomeFirstResponder()
            
        } else {
            navigationItem.rightBarButtonItem?.title = "Edit"
            addbutton.isHidden = false
            tfView.isHidden = true
            textField.resignFirstResponder()
        }
    }
}
