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
    
    enum Section {
        case main
    }
    typealias Item = Task
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
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
        
        // 임시 값 주입
        vm.lists[index].tasks.append(Task(id: 1, listId: vm.lists[index].id, title: "to study", isDone: false, isImportant: false))
        vm.lists[index].tasks.append(Task(id: 2, listId: vm.lists[index].id, title: "to eat", isDone: true, isImportant: true))
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell else { return nil }
            cell.configure(item)
            return cell
        })
        
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.lists[index].tasks, toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
    }
    
    // 임시
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.lists[index!].tasks = []
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
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
