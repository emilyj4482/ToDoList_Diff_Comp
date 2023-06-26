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
    
    // 임시 값
    var lists: [List] = [
        List(id: 1, name: "Important", tasks: [Task(id: 1, listId: 1, title: "important task", isDone: false, isImportant: true)]),
        List(id: 2, name: "to study", tasks: [Task(id: 1, listId: 2, title: "iOS", isDone: false, isImportant: false)])
    ]
    
    // diffable data source 정의 : 단일 섹션
    enum Section {
        case main
    }
    typealias Item = List
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListCell else { return nil }
            cell.configure(item)
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        // 임시 값 주입
        snapshot.appendItems(lists, toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        
        updateCountLabel()
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
    
    // list count label 뷰 적용
    func updateCountLabel() {
        let count = lists.count - 1
        if count <= 1 {
            listCountLabel.text = "You have \(count) custom list."
        } else {
            listCountLabel.text = "You have \(count) custom lists."
        }
    }

    @IBAction func addListButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddNewListViewController") as? AddNewListViewController else { return }
        
        present(vc, animated: true)
    }
    
}

