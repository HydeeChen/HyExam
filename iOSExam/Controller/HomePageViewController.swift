//
//  HomePageViewController.swift
//  iOSExam
//
//  Created by Hydee Chen on 2024/3/8.
//

import UIKit
import Combine
import Kingfisher
import Security


class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 宣告符合api資料結構的變數items
    @Published var items: [UserListDatum] = []
    
    private var anyCancelables = Set<AnyCancellable>()
    
    // 設定api之url
    let examURL = URL(string:"https://mservice.ebook.hyread.com.tw/exam/user-list")
    
    // 設定collectionView實體
    var collectionView: UICollectionView!
    
    // 建立一個 ApiHelper 物件
    let apiHelper = ApiHelper()
    
    // 設定儲存UUID的set
    @Published var uuidSet = Set<Int>()
    
    // 修改會員資料按鈕outlet
    @IBOutlet weak var replaceDataButtonOutlet: UIButton!
    
    
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
        
        $items
            .combineLatest($uuidSet)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items, set in
                self?.collectionView.reloadData()
            }.store(in: &anyCancelables)
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
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.likeButton.tintColor = .white
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
    
    // 修改會員資料按鈕之function
    @IBAction func pressButton(_ sender: Any) {
        // 假設你有用戶名稱需要存儲到 Keychain 中
                let newUsername = "hydee"

                // 呼叫 Keychain 相關方法保存資料
                saveToKeychain(username: newUsername)
                print(newUsername)
    }
    // Keychain 相關方法
        func saveToKeychain(username: String) {
            // 以 kSecClassGenericPassword 作為識別，這裡以 username 作為帳號
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: "username", // 這裡可以自定義 Keychain 中的帳號識別
                kSecValueData: username.data(using: .utf8)!,
                kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ] as CFDictionary

            // 先刪除現有的資料，再保存新的資料
            SecItemDelete(query)

            // 添加新的資料到 Keychain
            let status = SecItemAdd(query, nil)
            guard status == errSecSuccess else {
                print("Failed to save data to Keychain.")
                return
            }
            print("Data saved to Keychain.")
        }
}

extension HomePageViewController: HomePageCollectionViewCellDelegate {
    func HomePageCollectionViewCell(_Cell: HomePageCollectionViewCell, didPressLikeButton Button: Any) {
        if let indexPath = collectionView.indexPath(for: _Cell) {
            let selectedItem = items[indexPath.row]
            didPressLikeButtonFor(uuid: selectedItem.uuid)
        }
    }
    
    func didPressLikeButtonFor(uuid: Int) {
        if uuidSet.contains(uuid) {
            uuidSet.remove(uuid)
        } else {
            uuidSet.insert(uuid)
        }
        saveUUIDSetToUserDefaults()
    }
    
    func saveUUIDSetToUserDefaults() {
        let uuidArray = Array(uuidSet)
        if let encodedData = try? JSONEncoder().encode(uuidArray) {
            UserDefaults.standard.set(encodedData, forKey: "uuidSet")
            
        }
    }
}
