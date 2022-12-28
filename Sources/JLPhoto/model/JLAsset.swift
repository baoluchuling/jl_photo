//
//  JLAsset.swift
//  JanLi
//
//  Created by admin on 2021/10/22.
//  Copyright © 2021 com.baoluchuling.janli. All rights reserved.
//

import UIKit
import Photos

public struct JLAsset: Hashable {
    
    public static func == (lhs: JLAsset, rhs: JLAsset) -> Bool {
        return lhs.asset == rhs.asset
    }
    
    var asset: PHAsset?
    
    var data: Data?
    
    public init(asset: PHAsset?) {
        self.asset = asset
    }
    
    public init(data: Data?) {
        self.data = data
    }
    
    public func fetchThumb(with size: CGSize, handle: @escaping (Data?) -> Void) -> Void {
        guard data == nil else {
            handle(data)
            return
        }
        
        JLAssetManager.default.fetchThumb(with: self, size: size, handle: handle)
    }
}

public class JLAssetManager {
    static let `default` = JLAssetManager()
    
    public func fetchThumb(with asset: JLAsset?, size: CGSize, handle: @escaping (Data?) -> Void) -> Void {
        DispatchQueue.global().async {
            guard let photoAsset = asset?.asset else {
                handle(nil)
                return
            }
            
            let opt = PHImageRequestOptions()
            opt.version = .current
                        
            PHCachingImageManager.default().requestImage(for: photoAsset, targetSize: size, contentMode: .aspectFill, options: opt) { image, info in
                autoreleasepool { // 峰值内存占用减少大约1m
                    DispatchQueue.main.async {
                        handle(image?.pngData())
                    }
                }
            }
        }
    }
    
    public func fetchOrigin(with asset: JLAsset?, size: CGSize?, handle: @escaping (Data?) -> Void) -> Void {
        DispatchQueue.global().async {
            guard let photoAsset = asset?.asset else {
                handle(nil)
                return
            }
            
            let opt = PHImageRequestOptions()
            opt.version = .current
            
            PHCachingImageManager.default().requestImageDataAndOrientation(for: photoAsset, options: opt) { data, name, orientation, info in
                DispatchQueue.main.async {
                    handle(data)
                }
            }
        }
    }
}
