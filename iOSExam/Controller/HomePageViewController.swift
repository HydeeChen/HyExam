//
//  HomePageViewController.swift
//  iOSExam
//
//  Created by Hydee Chen on 2024/3/8.
//

import UIKit
import Kingfisher

class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 宣告符合api資料結構的變數items
    var items: [UserListDatum]!
    
    // 設定api之url
    let examURL = URL(string:"https://mservice.ebook.hyread.com.tw/exam/user-list")
    
    // 設定collectionView實體
    var collectionView: UICollectionView!
    
    // 建立一個 ApiHelper 物件
    let apiHelper = ApiHelper()
    
    // 設定初始是否為收藏書籍
    var likeThisBook = false
    
    // 設定儲存UUID的set
    var uuidSet = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定collectionView
        let layoutPersonal = UICollectionViewFlowLayout()
        layoutPersonal.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 0)
        layoutPersonal.minimumLineSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.minimumInteritemSpacing = CGFloat(integerLiteral: 10)
        layoutPersonal.scrollDirection = UICollectionView.ScrollDirection.vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutPersonal)
        
        // collectionView資料源設定
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(iOSExam.HomePageCollectionViewCell.self as AnyClass, forCellWithReuseIdentifier: iOSExam.HomePageCollectionViewCell.cellID)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        // 把myCollectioniew加到畫面裡
        view.addSubview(collectionView)
        
        // collection自動調整關閉
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // CollectionView的限制
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
        ])
        
        if let apiUrl = examURL {
            let apiHelper = ApiHelper()
            apiHelper.loadUserList(apiUrl: apiUrl) { items in
                if let items = items {
                    // API 請求成功
                    self.items = items
                    DispatchQueue.main.async {
                          self.collectionView.reloadData()
                        }
                } else {
                    // API 請求失敗
                    // 顯示錯誤訊息
                    // 或使用之前成功過的 cache
                }
            }
        }
        loadUUIDSetFromUserDefaults()
        print("uuidSet after loading from UserDefaults: \(uuidSet)")
        
    }
    
    
    // 設定collectionView的item數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 待處理
        return items.count
    }
    
    // 設定collectionView的item內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomePageCollectionViewCell", for: indexPath) as? HomePageCollectionViewCell else {
            fatalError("Unable to dequeue HomePageCollectionViewCell")
        }
        let item = items[indexPath.row]
        if let coverURL = URL(string: item.coverUrl) {
            cell.bookImageView.kf.setImage(with: coverURL)
        }
        cell.update(bookData: item)
        cell.delegate = self
        
        // 設置 likeButton 狀態
        if uuidSet.contains(item.uuid) {
            cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.likeButton.tintColor = .systemMint
            likeThisBook = true
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.likeButton.tintColor = .white
            likeThisBook = false
        }
        
        return cell
    }
    
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150) // 調整 cell 大小
    }
    
    func loadUUIDSetFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: "uuidSet"),
           let uuidArray = try? JSONDecoder().decode([Int].self, from: savedData) {
            uuidSet = Set(uuidArray)
        }
    }
    
}

extension HomePageViewController: HomePageCollectionViewCellDelegate {
    func HomePageCollectionViewCell(_Cell: HomePageCollectionViewCell, didPressLikeButton Button: Any) {
        if likeThisBook == false {
            _Cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            _Cell.likeButton.tintColor = .systemMint
            likeThisBook = true
            if let indexPath = collectionView.indexPath(for: _Cell) {
                let selectedItem = items[indexPath.row]
                
                // 存入uuid set
                uuidSet.insert(selectedItem.uuid)
                print(uuidSet)
                saveUUIDSetToUserDefaults()
            }
            
        } else {
            _Cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            _Cell.likeButton.tintColor = .white
            likeThisBook = false
            if let indexPath = collectionView.indexPath(for: _Cell) {
                let selectedItem = items[indexPath.row]
                
                // 刪除uuid set
                uuidSet.remove(selectedItem.uuid)
                print(uuidSet)
                saveUUIDSetToUserDefaults()
            }
        }
    }
    func saveUUIDSetToUserDefaults() {
        let uuidArray = Array(uuidSet)
        if let encodedData = try? JSONEncoder().encode(uuidArray) {
            UserDefaults.standard.set(encodedData, forKey: "uuidSet")
        }
    }
}
