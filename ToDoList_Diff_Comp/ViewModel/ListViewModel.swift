//
//  TaskViewModel.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/26.
//

import Foundation

class ListViewModel {
    static let shared = ListViewModel()
    
    // disk에 in app data json 파일로 저장
    private let dm = DataManager.shared
    
    // List.id 저장용 프로퍼티
    private var lastListId: Int = 1
    
    // Important list는 고정값
    // lists에 변동이 생길 때마다 로컬에 저장 : didSet
    @Published var lists: [List] = [List(id: 1, name: "Important", tasks: [])] {
        didSet {
            dm.savaData(lists)
        }
    }
    
    /* task.isDone 여부에 따라 section 분리할 때 사용할 Array
    var undoneTasks: [Task] = []
    var doneTasks: [Task] = []
    */
    
    func createList(_ listName: String) -> List {
        let nextId = lastListId + 1
        lastListId = nextId
        
        return List(id: nextId, name: listName, tasks: [])
    }
    
    func addList(_ list: List) {
        lists.append(list)
    }
    
    // Task 내용은 중복 허용(검사 X), 입력값에 대해 앞뒤 공백을 제거해준 뒤 생성한다.
    func createTask(listId: Int, _ title: String) -> Task {
        return Task(listId: listId, title: title.trim(), isDone: false, isImportant: false)
    }
    
    func addTask(listId: Int, _ task: Task) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].tasks.append(task)
        }
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 업데이트 필요
    func updateTaskComplete(_ task: Task) {
        if task.isImportant {
            updateSingleTask(listId: 1, taskId: task.id, task: task)
        }
        updateSingleTask(listId: task.listId, taskId: task.id, task: task)
    }
    
    private func updateSingleTask(listId: Int, taskId: UUID, task: Task) {
        if let index1 = lists.firstIndex(where: { $0.id == listId }) {
            if let index2 = lists[index1].tasks.firstIndex(where: { $0.id == taskId }) {
                lists[index1].tasks[index2].update(title: task.title, isDone: task.isDone, isImportant: task.isImportant)
            }
        }
    }
    
    // isImportant update : Important list로의 추가/삭제 함께 동작 필요
    func updateImportant(_ task: Task) {
        if task.isImportant {
            lists[0].tasks.append(task)
        } else {
            if let index = lists[0].tasks.firstIndex(where: { $0.id == task.id }) {
                lists[0].tasks.remove(at: index)
            }
        }
        updateSingleTask(listId: task.listId, taskId: task.id, task: task)
    }
    
    func updateList(listId: Int, _ name: String) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists[index].update(name: name)
        }
    }
    
    func deleteList(listId: Int) {
        if let index = lists.firstIndex(where: { $0.id == listId }) {
            lists.remove(at: index)
        }
    }
    
    // important task인 경우 Important list와 속한 list 양쪽에서 삭제 처리 필요
    func deleteTaskComplete(_ task: Task) {
        if task.isImportant {
            deleteSingleTask(listId: 1, taskId: task.id)
        }
        deleteSingleTask(listId: task.listId, taskId: task.id)
    }
    
    private func deleteSingleTask(listId: Int, taskId: UUID) {
        if let index1 = lists.firstIndex(where: { $0.id == listId }) {
            if let index2 = lists[index1].tasks.firstIndex(where: { $0.id == taskId }) {
                lists[index1].tasks.remove(at: index2)
            }
        }
    }
    
    /*
    // task.isDone 여부에 따라 Array 구분
    func filterTasks(_ listIndex: Int) {
        undoneTasks = lists[listIndex].tasks.filter({ $0.isDone == false })
        doneTasks = lists[listIndex].tasks.filter({ $0.isDone == true })
    }
    
    // task.isDone 값이 변경될 때마다 Array 간 이동
    func moveSection(_ task: Task) {
        if task.isDone == true {
            undoneTasks.removeAll(where: { $0.id == task.id})
            doneTasks.append(task)
        } else {
            doneTasks.removeAll(where: { $0.id == task.id })
            undoneTasks.append(task)
        }
    }
    */
    
    // disk에서 저장된 data를 불러와 lists 및 lastListId 값에 적용
    func retrieveLists() {
        lists = dm.loadData()
        
        let lastId = lists.last?.id
        lastListId = lastId ?? 1
    }
}

// 문자열 앞뒤 공백 삭제 메소드 정의
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
