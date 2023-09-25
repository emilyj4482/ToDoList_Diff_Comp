//
//  ToDoListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit
import Combine

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addbutton: UIButton!
    
    var vm = ListViewModel.shared
    
    var index: Int?
    
    enum Section {
        case main
    }
    typealias Item = Task
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let index = index else { return }
        print(vm.lists[index])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        
        // important list일 때는 task 추가 및 listname 수정 기능 잠금
        if index == 0 {
            addbutton.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
        }
        
        configureCollectionView()
        bind()
    }
    
    private func configureCollectionView() {
        // data source
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard
                let index = self.index,
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCell", for: indexPath) as? TaskCell
            else { return UICollectionViewCell() }
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
        
        // layout
        collectionView.collectionViewLayout = layout()
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        
        // swipe to update & delete
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            guard let item = self.datasource.itemIdentifier(for: indexPath) else { return nil }
            
            // task update : modal view로 데이터를 전송하며 이동
            let updateAction = UIContextualAction(style: .normal, title: "EDIT") { _, _, completion in
                guard
                    let index = self.index,
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskEditViewController") as? TaskEditViewController
                else { return }
                vc.index = index
                vc.isCreating = false
                vc.taskToEdit = item
                self.present(vc, animated: true)
                completion(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "DELETE") { [unowned self] _, _, _ in
                vm.deleteTaskComplete(item)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func bind() {
        guard let index = index else { return }
        vm.$lists
            .receive(on: RunLoop.main)
            .sink { lists in
                var tasks = lists[index].tasks
                // collection view update
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                snapshot.appendItems(tasks, toSection: .main)
                self.datasource.apply(snapshot)
            }
            .store(in: &subscriptions)
    }
    
    @objc func editButtonTapped() {
        guard let index = index else { return }
        let list = vm.lists[index]
        
        // textfield를 가진 alert 창을 띄워 list 이름 수정 기능 제공
        let editAlert = UIAlertController(title: "Type your new list name down below.", message: "", preferredStyle: .alert)
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel)
        let btnDone = UIAlertAction(title: "Done", style: .default, handler: { [unowned self] _ in
            guard let tfText = editAlert.textFields?[0].text?.trim() else { return }
            
            if !tfText.isEmpty {
                vm.updateList(listId: list.id, tfText)
                navigationItem.title = tfText
            }
        })
        
        editAlert.addTextField { tf in
            tf.placeholder = list.name
        }
        editAlert.addAction(btnCancel)
        editAlert.addAction(btnDone)
        
        present(editAlert, animated: true)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard
            let index = index,
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TaskEditViewController") as? TaskEditViewController
        else { return }
        vc.index = index
        present(vc, animated: true)
    }
}
