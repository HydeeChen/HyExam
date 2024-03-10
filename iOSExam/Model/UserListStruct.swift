//
//  UserListStruct.swift
//  iOSExam
//
//  Created by Hydee Chen on 2024/3/8.
//

import Foundation

// 符合打api的Struct
struct UserListDatum: Codable {
    let uuid: Int
    let title: String
    let coverUrl: String
    let publishDate: String
    let publisher: String
    let author: String
}
