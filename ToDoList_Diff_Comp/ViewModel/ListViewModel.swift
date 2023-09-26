//
//  ListViewModel.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/06/26.
//

import Foundation

final class ListViewModel {
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
    
    func createList(_ listName: String) -> List {
        let nextId = lastListId + 1
        lastListId = nextId
        
        return List(id: nextId, name: listName, tasks: [])
    }
    
    func addList(_ list: List) {
        lists.append(list)
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
