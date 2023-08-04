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
        
        // 키보드 감지
        detectKeyboard()
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell else { return UICollectionViewCell() }
            cell.configure(item)
            
            // TODO: done & star 버튼 tap에 따른 데이터 변경
            var task = self.vm.lists[index].tasks[indexPath.item]
            
            cell.doneButtonTapHandler = { isDone in
                task.isDone = isDone
                print(task)
            }
            
            cell.starButtonTapHandler = { isImportant in
                task.isImportant = isImportant
                print(task)
            }
            
            return cell
        })
        
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.lists[index].tasks, toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
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
        // Done 버튼 tap 시 textfield 입력값으로 task 추가
        guard let title = textField.text?.trim() else { return }
        
        if let index = index, !title.isEmpty {
            let list = vm.lists[index]
            let task = vm.createTask(listId: list.id, title)
            vm.addTask(listId: list.id, task)
            
            // reload collection view
            snapshot.appendItems([task], toSection: .main)
            datasource.apply(snapshot)
        }
        
        // test code
        addTaskMode = false
        
        print(vm.lists)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
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
    
    // keyboard detection
    func detectKeyboard() {
        // 키보드가 나타나는 것 감지 >> keyboardWillShow 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 키보드가 사라지는 것 감지 >> keyboardWillHide 함수 호출
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        // keyboard 크기 > 높이 추출
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight = keyboardFrame.height
        // 적용할 높이 = keyboard 높이 - safe area 높이
        let adjustmentHeight = keyboardHeight - view.safeAreaInsets.bottom
        // 적용할 높이만큼 textfield 영역 높임
        tfViewBottom.constant = adjustmentHeight
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        // textfield 영역 높이 원점
        tfViewBottom.constant = 0
        // textfield 비우기
        textField.text = ""
    }
}
