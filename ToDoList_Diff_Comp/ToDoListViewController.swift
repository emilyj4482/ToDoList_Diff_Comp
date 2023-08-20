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
        case undone
        case done
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
        
        // star button tap noti
        NotificationCenter.default.addObserver(self, selector: #selector(starButtonTapped), name: NSNotification.Name(rawValue: "starButtonTapped"), object: nil)
        
        // done button tap noti
        NotificationCenter.default.addObserver(self, selector: #selector(doneButtonTapped), name: NSNotification.Name("doneButtonTapped"), object: nil)
        
        // 키보드 감지
        detectKeyboard()
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell else { return UICollectionViewCell() }
            cell.configure(item)
            
            // done & star 버튼 tap에 따른 데이터 변경
            var task = self.vm.lists[index].tasks[indexPath.item]
            
            cell.doneButtonTapHandler = { [unowned self] isDone in
                task.isDone = isDone
                vm.updateTaskComplete(task)
            }
            
            cell.starButtonTapHandler = { [unowned self] isImportant in
                task.isImportant = isImportant
                vm.updateImportant(task)
            }
            
            return cell
        })
        
        reload()
        
        collectionView.collectionViewLayout = layout()
        
        // header
        collectionView.register(TaskDoneHeader.self, forSupplementaryViewOfKind: "TaskDoneHeader", withReuseIdentifier: "TaskDoneHeader")
        
        datasource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TaskDoneHeader", for: indexPath) as? TaskDoneHeader else { return UICollectionReusableView() }
            // task done section에만 header 표시
            if indexPath.section == 0 {
                header.isHidden = true
            } else if collectionView.numberOfItems(inSection: 1) == 0 {
                header.isHidden = true
            } else {
                header.isHidden = false
            }
            return header
        }
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        
        // swipe to update & delete
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.headerMode = .supplementary
        config.headerTopPadding = 0
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            var item = self.datasource.itemIdentifier(for: indexPath)
            let updateAction = UIContextualAction(style: .normal, title: "EDIT") { _, _, completion in
                // textfield를 가진 alert 창을 띄워 task 이름 수정 기능 제공
                let editAlert = UIAlertController(title: "Modifying task?", message: "", preferredStyle: .alert)
                let btnCancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    completion(true)
                }
                let btnDone = UIAlertAction(title: "Done", style: .default, handler: { [unowned self] _ in
                    guard let tfText = editAlert.textFields?[0].text?.trim() else { return }
                    if !tfText.isEmpty {
                        item?.title = tfText
                    }
                    guard let item = item else { return }
                    vm.updateTaskComplete(item)
                    completion(true)
                    reload()
                })
                editAlert.addTextField { tf in
                    tf.placeholder = item?.title
                }
                editAlert.addAction(btnCancel)
                editAlert.addAction(btnDone)
                
                self.present(editAlert, animated: true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "DELETE") { [unowned self] _, _, _ in
                guard let item = item else { return }
                vm.deleteTaskComplete(item)
                snapshot.deleteItems([item])
                datasource.apply(self.snapshot)
            }
            return UISwipeActionsConfiguration(actions: [updateAction, deleteAction])
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    // important list에서 star button tap 시 task 사라지도록 처리 (view reload)
    @objc func starButtonTapped(_ noti: Notification) {
        guard
            let index = index,
            index == 0,
            let isImportant = noti.object as? Bool,
            isImportant == false
        else { return }

        reload()
    }
    
    // done toggle 시 done, undone section 간 item 이동 구현
    @objc func doneButtonTapped(_ noti: Notification) {
        
    }
    
    // view reload
    private func reload() {
        guard let index = index else { return }
        snapshot.deleteAllItems()
        snapshot.appendSections([.undone, .done])
        snapshot.appendItems(vm.undoneTasks(index), toSection: .undone)
        snapshot.appendItems(vm.doneTasks(index), toSection: .done)
        datasource.apply(snapshot)
    }
    
    // header reload : task done section 발생에 따라 header 노출
    private func headerReload(_ item: Task, _ indexPath: IndexPath) {
        if item.isDone == true {
            collectionView.supplementaryView(forElementKind: "UICollectionElementKindSectionHeader", at: indexPath)?.isHidden = false
        } else if item.isDone == false && collectionView.numberOfItems(inSection: 1) != 0 {
            collectionView.supplementaryView(forElementKind: "UICollectionElementKindSectionHeader", at: indexPath)?.isHidden = false
        } else {
            collectionView.supplementaryView(forElementKind: "UICollectionElementKindSectionHeader", at: indexPath)?.isHidden = true
        }
    }
    
    /*
     우측 상단 button : Edit or Done
     Edit : list 이름 수정
     Done : task 추가
    */
    @objc func rightButtonTapped() {
        guard let index = index else { return }
        let list = vm.lists[index]
        
        // add task mode true = Done
        // >> textfield 입력값으로 task 추가
        if addTaskMode == true {
            guard let title = textField.text?.trim() else { return }
            
            if !title.isEmpty {
                let task = vm.createTask(listId: list.id, title)
                vm.addTask(listId: list.id, task)
                
                // reload collection view
                snapshot.appendItems([task], toSection: .undone)
                datasource.apply(snapshot)
            }
            
            addTaskMode = false
            
            print(vm.lists)
        } else {
            // add task mode false = Edit
            // >> textfield를 가진 alert 창을 띄워 list 이름 수정 기능 제공
            let editAlert = UIAlertController(title: "Type your new list name down below.", message: "", preferredStyle: .alert)
            let btnCancel = UIAlertAction(title: "Cancel", style: .cancel)
            let btnDone = UIAlertAction(title: "Done", style: .default, handler: { _ in
                guard let tfText = editAlert.textFields?[0].text else { return }
                self.vm.updateList(listId: list.id, tfText)
                self.navigationItem.title = tfText
            })
            
            editAlert.addTextField { tf in
                tf.placeholder = list.name
            }
            editAlert.addAction(btnCancel)
            editAlert.addAction(btnDone)
            
            present(editAlert, animated: true)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
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
