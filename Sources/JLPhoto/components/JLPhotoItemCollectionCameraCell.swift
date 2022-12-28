//
//  JLCollectionViewCameraCell.swift
//  JanLi
//
//  Created by admin on 2022/11/25.
//  Copyright © 2022 com.baoluchuling.janli. All rights reserved.
//

import UIKit

class JLPhotoItemCollectionCameraCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var addBtn: UIImageView?
    
    var selectView: JLSelectView?
    
    func setupView() -> Void {
        
        self.contentView.backgroundColor = UIColor.gray
        
        self.addBtn = UIImageView()
        self.addBtn!.backgroundColor = UIColor.clear
        self.addBtn?.tintColor = UIColor.white
        self.addBtn!.image = UIImage(systemName: "camera")
        self.contentView.addSubview(self.addBtn!)
        
        self.addBtn!.snp.makeConstraints { make in
            make.width.equalTo(95 * 0.6)
            make.height.equalTo(74 * 0.6)
            make.center.equalToSuperview()
        }
    }
}
