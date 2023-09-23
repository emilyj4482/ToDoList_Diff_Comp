//
//  MainListViewController.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class MainListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var listCountLabel: UILabel!
    
    var vm = TaskViewModel.shared
    
    // diffable data source 정의 : 단일 섹션
    enum Section {
        case main
    }
    typealias Item = List
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disk에 저장돼있는 data 불러오기
        vm.retrieveLists()
        
        // modal dismiss noti
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name(rawValue: "newListAdded"), object: nil)
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListCell else { return nil }
            cell.configure(item)
            return cell
        })
        
        reload()
        
        collectionView.collectionViewLayout = layout()
        
        updateCountLabel()
        
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // todo list view에서 돌아올 때마다 view reload (데이터 수정사항 적용)
        snapshot.deleteAllItems()
        reload()
    }
    
    // view reload
    private func reload() {
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.lists, toSection: .main)
        datasource.apply(snapshot)
    }
    
    // list count label 뷰 적용
    func updateCountLabel() {
        let count = vm.lists.count - 1
        if count <= 1 {
            listCountLabel.text = "You have \(count) custom list."
        } else {
            listCountLabel.text = "You have \(count) custom lists."
        }
    }
    
    private func layout() -> UICollectionViewCompositionalLayout {
        
        // swipe to delete
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            // Important list는 삭제 불가능 >> swipe action 적용하지 않음
            if indexPath.item != 0 {
                let item = self.datasource.itemIdentifier(for: indexPath)
                let action = UIContextualAction(style: .destructive, title: "DELETE") { [unowned self] _, _, completion in
                    guard let item = item else { return }
                    showActionSheet(item)
                    completion(true)
                }
                return UISwipeActionsConfiguration(actions: [action])
            }
            return UISwipeActionsConfiguration(actions: [])
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    // action sheet
    private func showActionSheet(_ item: Item) {
        let alert = UIAlertController(title: "Are you sure deleting the list?", message: "", preferredStyle: .actionSheet)
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteItem(item)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
    
    // delete item
    private func deleteItem(_ item: Item) {
        // 삭제 대상 list가 important task를 포함하고 있을 때, list에 속했던 important task들이 Important list에서도 삭제되어야 한다.
        if item.tasks.contains(where: { $0.isImportant }) {
            vm.lists[0].tasks.removeAll(where: { $0.listId == item.id && $0.isImportant })
        }
        
        vm.deleteList(listId: item.id)
        snapshot.deleteAllItems()
        reload()
        updateCountLabel()
    }

    @IBAction func addListButtonTapped(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddNewListViewController") as? AddNewListViewController else { return }
        present(vc, animated: true)
    }
    
    // new list 추가 시 collection view에 적용
    @objc func reloadCollectionView() {
        snapshot.appendItems([vm.lists.last!], toSection: .main)
        datasource.apply(snapshot)
        updateCountLabel()
    }
    
}

extension MainListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = vm.lists[indexPath.item]
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ToDoListViewController") as? ToDoListViewController else { return }
        
        vc.title = list.name
        vc.index = indexPath.item
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
