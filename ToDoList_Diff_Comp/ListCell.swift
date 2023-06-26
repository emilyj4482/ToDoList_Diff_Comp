//
//  ListCell.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class ListCell: UICollectionViewCell {
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var taskCountLabel: UILabel!
    
    func configure(_ list: List) {
        // important list는 별 image
        if list.id == 1 {
            listImage.image = UIImage(systemName: "star.fill")
        } else {
            listImage.image = UIImage(systemName: "checklist.checked")
        }
        listNameLabel.text = list.name
        taskCountLabel.text = "\(list.tasks.count)"
    }
}
