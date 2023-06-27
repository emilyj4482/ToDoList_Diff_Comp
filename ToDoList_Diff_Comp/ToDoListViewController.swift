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
    
    var vm = TaskViewModel.shared
    
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let index = index else { return }
        print(vm.lists[index])
        
        barButtons()
        
        // important list일 때는 task 추가 및 listname 수정 기능 잠금
        if index == 0 {
            addbutton.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
        }
    }
    
    private func barButtons() {
        let rightBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(rightButtonTapped))
        rightBarButton.tintColor = .systemPink
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func rightButtonTapped() {
        print("right btn tapped")
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        print("add btn tapped")
    }
    
}
