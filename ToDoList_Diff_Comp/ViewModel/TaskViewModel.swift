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
    
    @Published var tasks: [Task] = []
    
    // tasks에 변동이 생길 때마다 lvm.lists에 update
    private func syncTasks() {
        lvm.lists[index].tasks = tasks
    }
    
    func createTask(listId: Int, _ title: String) -> Task {
        return Task(listId: listId, title: title, isDone: false, isImportant: false)
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        syncTasks()
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 update 필요
    func updateTaskComplete(_ task: Task) {
        if task.isImportant && index == 0 {
            updateOriginalTask(task)
        } else if task.isImportant && index != 0,
                  let index = lvm.lists[0].tasks.firstIndex(where: { $0.id == task.id }) {
            lvm.lists[0].tasks[index].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
        }
        updateSingleTask(task)
        syncTasks()
    }
    
    private func updateSingleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
        }
    }
    
    // 현재 화면이 important list일 때 task가 속한 list에서도 update
    private func updateOriginalTask(_ task: Task) {
        if let index1 = lvm.lists.firstIndex(where: { $0.id == task.listId }),
           let index2 = lvm.lists[index1].tasks.firstIndex(where: { $0.id == task.id }) {
            lvm.lists[index1].tasks[index2].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
        }
    }
    
    // isImportant update : Important list로의 추가/삭제 동작 함께 필요
    func updateImportant(_ task: Task) {
        if task.isImportant {
            lvm.lists[0].tasks.append(task)
            updateSingleTask(task)
        } else {
            if index == 0 {
                tasks.removeAll(where: { $0.id == task.id })
                updateOriginalTask(task)
            } else {
                updateSingleTask(task)
                lvm.lists[0].tasks.removeAll(where: { $0.id == task.id })
            }
        }
        syncTasks()
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 삭제 처리 필요
    func deleteTaskComplete(_ task: Task) {
        if task.isImportant && index == 0,
           let index = lvm.lists.firstIndex(where: { $0.id == task.listId }) {
            lvm.lists[index].tasks.removeAll(where: { $0.id == task.id })
        } else if task.isImportant && index != 0 {
            lvm.lists[0].tasks.removeAll(where: { $0.id == task.id })
        }
        deleteSingleTask(task)
        syncTasks()
    }
    
    private func deleteSingleTask(_ task: Task) {
        tasks.removeAll(where: { $0.id == task.id })
    }
}
