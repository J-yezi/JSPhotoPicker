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

extension PHAsset {
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

extension Array where Element == PHAsset {
    public func requestImages(targetSize: AssetSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) -> [UIImage] {
        var o = options
        if o == nil {
            o = PHImageRequestOptions()
        }
        o?.isSynchronous = true
        
        var images = [UIImage]()
        forEach {
            var assetSize: CGSize = .zero
            switch targetSize {
            case .original:
                assetSize = CGSize(width: $0.pixelWidth, height: $0.pixelHeight)
            case .custom(let size):
                assetSize = size
            }
            PHCachingImageManager.default().requestImage(for: $0, targetSize: assetSize, contentMode: contentMode, options: o) { (image, _) in
                guard let image = image else { return }
                images.append(image)
            }
        }
        return images
    }
}

private var kStatusViewKey: Void?
private var kFullViewKey: Void?

//MARK: - Properties
extension UIApplication {
    /// 获取整个应用被present道最顶部的controller，方便后面使用该controller进行present
    var presentedController: UIViewController? {
        if let control = UIApplication.shared.keyWindow?.rootViewController {
            while control.presentedViewController != nil && control.presentedViewController?.isBeingDismissed == false {
                return control.presentedViewController!
            }
            return control
        }
        return nil
    }
    
    /// statusView.isHidden = false来打开这个遮挡状态栏的视图，默认是false
    var statusView: UIView? {
        get {
            if let shadeView = objc_getAssociatedObject(self, &kStatusViewKey) as? UIView {
                return shadeView
            }else {
                let shadeView = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
                shadeView.windowLevel = UIWindowLevelStatusBar
                shadeView.rootViewController = UIViewController()
                self.statusView = shadeView
                return shadeView
            }
        }
        set {
            objc_setAssociatedObject(self, &kStatusViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIImage {
    /// 改变图片颜色
    func tint(_ color: UIColor, blendMode: CGBlendMode = .normal) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(blendMode)
        
        let drawRect = CGRect(origin: CGPoint.zero, size: size)
        context.clip(to: drawRect, mask: cgImage!)
        color.setFill()
        context.fill(drawRect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    /// 目前是两张图的size都是一样的进行上下叠加
    func combine(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(at: CGPoint.zero)
        draw(at: CGPoint.zero)
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }
}
