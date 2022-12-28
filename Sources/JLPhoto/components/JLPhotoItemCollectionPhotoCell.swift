//
//  JLPhotoItemCollectionCell.swift
//  JanLi
//
//  Created by admin on 2021/10/22.
//  Copyright © 2021 com.baoluchuling.janli. All rights reserved.
//

import UIKit
import Photos

class JLPhotoItemCollectionPhotoCell: UICollectionViewCell {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var coverView: UIImageView?
    
    var selectView: JLSelectView?
    
    func setupView() -> Void {
        
        self.coverView = UIImageView()
        self.coverView?.backgroundColor = UIColor(named: "line")
        self.coverView?.contentMode = .scaleAspectFill
        self.coverView?.layer.cornerRadius = 4
        self.coverView?.layer.masksToBounds = true
        self.contentView.addSubview(self.coverView!)
        
        self.coverView?.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
        
        self.selectView = JLSelectView()
        self.selectView?.strokeColor = UIColor.white
        self.selectView?.selectColor = UIColor(named: "main")
        self.selectView?.select = false
        self.selectView?.layer.cornerRadius = 15 / 2
        self.contentView.addSubview(self.selectView!)
        
        self.selectView?.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
    }
    
    public func updateInfo(_ info: JLAsset?, click: @escaping (Bool) -> Void) {
        self.coverView?.jl_image(with: info)
        self.selectView?.click = click
    }
}
