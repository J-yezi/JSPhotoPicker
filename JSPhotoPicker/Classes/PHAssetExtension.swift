//
//  PHAssetExtension.swift
//  BSGridCollectionViewLayout
//
//  Created by jesse on 2017/7/22.
//

import UIKit
import Photos

public enum AssetSize {
    case original
    case custom(size: CGSize)
}

public extension PHAsset {
    public func requestImage(targetSize: AssetSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, isSynchronous: Bool = false, complete: @escaping (UIImage?) -> Void) {
        
        var o = options
        if o == nil {
            o = PHImageRequestOptions()
        }
        if isSynchronous {
            o?.isSynchronous = true
        }
        
        var assetSize: CGSize = .zero
        switch targetSize {
        case .original:
            assetSize = CGSize(width: pixelWidth, height: pixelHeight)
        case .custom(let size):
            assetSize = size
        }
        PHCachingImageManager.default().requestImage(for: self, targetSize: assetSize, contentMode: contentMode, options: o) { (image, _) in
            complete(image)
        }
    }
}
