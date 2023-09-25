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
    
    
}
