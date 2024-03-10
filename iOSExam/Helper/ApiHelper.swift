//
//  ApiHelper.swift
//  iOSExam
//
//  Created by Hydee Chen on 2024/3/10.
//

import Foundation

// 宣告符合api資料結構的變數items
var items = [UserListDatum]()

class ApiHelper {
    // 串接 api 之 function，將資料儲存於 items 變數
     func loadUserList(apiUrl: URL, completion: @escaping ([UserListDatum]?) -> Void) {
       var request = URLRequest(url: apiUrl)
       request.httpMethod = "GET"

       URLSession.shared.dataTask(with: request) { data, _, error in
         if let error = error {
           print("Error API: \(error)")
           // 在錯誤發生時，顯示警告或錯誤訊息
           completion(nil)
           return
         }

         guard let data = data else {
           print("Error: No data received.")
           completion(nil)
           return
         }

         // 解碼 JSON 格式的資料
         let decoder = JSONDecoder()
         do {
           let userListData = try decoder.decode([UserListDatum].self, from: data)
           completion(userListData)
         } catch {
           print("Error decoding JSON: \(error)")

         }
       }.resume()
     }
}
