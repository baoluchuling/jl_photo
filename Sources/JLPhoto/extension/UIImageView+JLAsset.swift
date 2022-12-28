//
//  UIImageView+Asset.swift
//  JanLi
//
//  Created by admin on 2022/12/1.
//  Copyright © 2022 com.baoluchuling.janli. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func jl_image(with asset: JLAsset?) {
        
        if self.bounds.size == CGSize.zero {
            self.layoutIfNeeded() // 不layout，取不到size
        }
                
        // 默认情况下，141.2m，不使用缩略图或者size为空，是500m
        JLAssetManager.default.fetchThumb(with: asset, size: self.bounds.size) { data in
            guard let data = data else {
                return
            }
            self.image = UIImage(data: data)
        }
    }
}
