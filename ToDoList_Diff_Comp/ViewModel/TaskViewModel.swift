//
//  TaskViewModel.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/09/26.
//

import Foundation

final class TaskViewModel {
    static let shared = TaskViewModel()
    
    private let lvm = ListViewModel.shared
    
    var list: List?
    
    var index: Int {
        guard let index = lvm.lists.firstIndex(where: { $0.id == list?.id }) else { return 0 }
        return index
    }
    
    @Published var tasks: [Task] = [] {
        didSet {
            // lvm.lists[index].tasks = tasks
        }
    }
    
    func createTask(listId: Int, _ title: String) -> Task {
        return Task(listId: listId, title: title, isDone: false, isImportant: false)
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 update 필요
    func updateTaskComplete(_ task: Task) {
        
        // 현재 위치가 Important list인 경우 >>> task가 속한 list에 접근하여 update
        if task.isImportant && index == 0,
           let index1 = lvm.lists.firstIndex(where: { $0.id == task.listId }),
           let index2 = lvm.lists[index1].tasks.firstIndex(where: { $0.id == task.id })
        { lvm.lists[index1].tasks[index2].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant) }
        
        // 현재 위치가 일반 list인 경우 >>> Important list에 접근하여 update
        else if task.isImportant && index != 0,
                let index = lvm.lists[0].tasks.firstIndex(where: { $0.id == task.id })
        { lvm.lists[0].tasks[index].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant) }
        
        // 공통 >>> 현재 위치에서 tasks에 접근하여 update
        updateSingleTask(task)
    }
    
    private func updateSingleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
        }
    }
    
    // isImportant update : Important list로의 추가/삭제 동작 함께 필요
    func updateImportant(_ task: Task) {
        if task.isImportant {
            lvm.lists[0].tasks.append(task)
        } else {
            // TODO: 현재 위치에 따라 동작 분리 더 필요
            lvm.lists[0].tasks.removeAll(where: { $0.id == task.id })
        }
        updateSingleTask(task)
    }
    
    
}
