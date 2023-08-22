//
//  DataManager.swift
//  ToDoList_Diff_Comp
//
//  Created by EMILY on 2023/08/22.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    // FileManager를 통해 disk에 data 저장
    private let fm = FileManager.default
    
    func savaData(_ lists: [List]) {
        guard let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(component: "todo.json") else { return }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(lists)
            if fm.fileExists(atPath: url.path) {
                try fm.removeItem(at: url)
            }
            fm.createFile(atPath: url.path, contents: data)
        } catch {
            print("ERROR >>> \(error)")
        }
    }
    
    // disk에서 data 불러옴
    func loadData() -> [List] {
        guard
            let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(component: "todo.json"),
            fm.fileExists(atPath: url.path),
            let data = fm.contents(atPath: url.path)
        else { return [List(id: 1, name: "Important", tasks: [])] }
        // >> 앱 최초 실행 시에도 Important list가 default로 있게 하기 위함.
        
        let decoder = JSONDecoder()
        
        do {
            let lists = try decoder.decode([List].self, from: data)
            return lists
        } catch {
            print("ERROR >>> \(error)")
            return []
        }
    }
}
