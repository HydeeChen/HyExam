//
//  HomePageCollectionViewCell.swift
//  iOSExam
//
//  Created by Hydee Chen on 2024/3/8.
//

import UIKit
import Kingfisher

// 設定按下按鈕的協定
protocol HomePageCollectionViewCellDelegate: AnyObject {
    func HomePageCollectionViewCell(_Cell: HomePageCollectionViewCell, didPressLikeButton Button: Any)
}

class HomePageCollectionViewCell: UICollectionViewCell {
    static let cellID: String = "HomePageCollectionViewCell"
    var bookImageView:UIImageView!
    var bookName:UILabel!
    var likeButton: UIButton!
    weak var delegate: HomePageCollectionViewCellDelegate?
    
    // 設定初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    // 設定初始化
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 設定初始化collectionView相關設定
    func configure() {
        // 設定書籍圖片大小
        bookImageView = UIImageView(frame: CGRect(x: contentView.frame.width * 0.1, y: contentView.frame.height * 0.2, width: contentView.frame.width * 0.9, height: contentView.frame.height * 0.7))
        bookImageView.layer.cornerRadius = 10
        bookImageView.layer.masksToBounds = true
        bookImageView.contentMode = .scaleAspectFill
        contentView.addSubview(bookImageView)
        
        // 設定書名label格式
        bookName = UILabel(frame: CGRect(x: 0, y: contentView.frame.height * 0.85, width: contentView.frame.width, height: contentView.frame.height / 2))
        bookName.textAlignment = .center
        bookName.font = UIFont.boldSystemFont(ofSize: 12) // 設定粗體
        bookName.textColor = .white // 設定白色文字
        bookName.numberOfLines = 3 // 設定為3行
        contentView.addSubview(bookName)
        
        // 新增收藏的like按鈕
        likeButton = createButton(imageName: "heart", action: #selector(likeButtonTapped(_:)))
        
        // 設定按鈕的 constraints
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            likeButton.widthAnchor.constraint(equalToConstant: 40), // 設定寬度
            likeButton.heightAnchor.constraint(equalToConstant: 40) // 設定高度
        ])
    }
    
    // 設定圖片與labe之資料更新源
    func update(bookData: UserListDatum) {
        if let coverURL = URL(string: bookData.coverUrl) {
                bookImageView.kf.setImage(with: coverURL)
            }
        bookName.text = bookData.title
    }
    
    // 設定製作按鈕的fuction
    func createButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.setTitle("", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.systemMint, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.addTarget(self, action: action, for: .touchUpInside)
        contentView.addSubview(button)
        return button
    }
    
    // 設定按下按鈕的功能
    @objc func likeButtonTapped(_ sender: UIButton) {
        delegate?.HomePageCollectionViewCell(_Cell: self, didPressLikeButton: "")
    }
    
}
