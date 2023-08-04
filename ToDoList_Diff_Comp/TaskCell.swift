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
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var starButtonTapHandler: ((Bool) -> Void)?
    
    func configure(_ task: Task) {
        doneButton.isSelected = task.isDone
        taskLabelStyle(task.isDone)
        taskLabel.text = task.title
        starButton.isSelected = task.isImportant
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        doneButton.isSelected.toggle()
        taskLabelStyle(doneButton.isSelected)
        
        // 데이터 변동 : doneButtonHandler에 isDone 여부 전송
        doneButtonTapHandler?(doneButton.isSelected)
    }
    
    @IBAction func starButtonTapped(_ sender: UIButton) {
        starButton.isSelected.toggle()
        
        // 데이터 변동 : starButtonHandler에 isImportant 여부 전송
        starButtonTapHandler?(starButton.isSelected)
    }
    
    // isDone 상태에 따라 task 글자 취소선, 흐리게 처리
    func taskLabelStyle(_ isDone: Bool) {
        if isDone {
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            taskLabel.alpha = 0.5
        } else {
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [.strikethroughStyle: NSUnderlineStyle()])
            taskLabel.alpha = 1
        }
    }
    
}
