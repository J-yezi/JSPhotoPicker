//
//  JSImageManager.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSImageManager {
    
    @discardableResult
    static func getPhoto(asset: PHAsset, width: CGFloat, options: PHImageRequestOptions? = nil, complete: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID {
        let size = CGSize(width: width * UIScreen.main.scale, height: CGFloat(asset.pixelHeight) / CGFloat(asset.pixelWidth) * width * UIScreen.main.scale)
        
        var o: PHImageRequestOptions? = nil
        if options == nil {
            o = PHImageRequestOptions()
            o?.resizeMode = .fast
        }else {
            o = options
        }
        
        return PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: o) { (image, result) in
            complete(image, result)
        }
    }
    
    static func cancelRequest(requestID id: PHImageRequestID) {
        PHCachingImageManager.default().cancelImageRequest(id)
    }
}
