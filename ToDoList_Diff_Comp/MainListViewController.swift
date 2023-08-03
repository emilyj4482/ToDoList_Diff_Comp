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
        
        // modal dismiss noti
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: NSNotification.Name(rawValue: "newListAdded"), object: nil)
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as? ListCell else { return nil }
            cell.configure(item)
            return cell
        })
        
        snapshot.appendSections([.main])
        snapshot.appendItems(vm.lists, toSection: .main)
        datasource.apply(snapshot)
        
        collectionView.collectionViewLayout = layout()
        
        updateCountLabel()
        
        collectionView.delegate = self
    }
    
    // test code
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(datasource.snapshot().itemIdentifiers)
        
        // todo view에서 tasks 전달 받고 snapshot에 update 하기
        
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
        let count = vm.lists.count - 1
        if count <= 1 {
            listCountLabel.text = "You have \(count) custom list."
        } else {
            listCountLabel.text = "You have \(count) custom lists."
        }
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
