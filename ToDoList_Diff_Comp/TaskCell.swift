//
//  TaskCell.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/23.
//

import UIKit

class TaskCell: UICollectionViewCell {
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    
    func configure(_ task: Task) {
        doneButton.isSelected = task.isDone
        taskLabel.text = task.title
        starButton.isSelected = task.isImportant
    }
}
