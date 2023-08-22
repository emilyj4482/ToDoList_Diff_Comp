//
//  Task.swift
//  ToDoList
//
//  Created by EMILY on 2023/03/30.
//

import Foundation

/* Model */

// 할 일 Object
struct Task: Codable, Hashable {
    var id = UUID()
    let listId: Int
    var title: String
    var isDone: Bool
    var isImportant: Bool
    
    mutating func update(title: String, isDone: Bool, isImportant: Bool) {
        self.title = title
        self.isDone = isDone
        self.isImportant = isImportant
    }
}

// 리스트 Object
struct List: Codable, Hashable {
    let id: Int
    var name: String
    var tasks: [Task]
    
    mutating func update(name: String) {
        self.name = name
    }
}
