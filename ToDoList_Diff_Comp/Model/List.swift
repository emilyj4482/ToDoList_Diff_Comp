//
//  List.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/09/26.
//

import Foundation

// 리스트 Object
struct List: Codable, Hashable {
    let id: Int
    var name: String
    var tasks: [Task]
    
    mutating func update(name: String) {
        self.name = name
    }
}
