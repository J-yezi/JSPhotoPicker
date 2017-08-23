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
    
    /// 默认异步方法
    @discardableResult
    public func requestImage(targetSize: AssetSize, contentMode: PHImageContentMode = .aspectFill, options: PHImageRequestOptions? = nil, complete: ((UIImage?, [AnyHashable : Any]?) -> Void)? = nil) -> PHImageRequestID {
        var assetSize: CGSize = .zero
        switch targetSize {
        case .original:
            assetSize = CGSize(width: pixelWidth, height: pixelHeight)
        case .custom(let size):
            assetSize = size
        }
        return PHCachingImageManager.default().requestImage(for: self, targetSize: assetSize, contentMode: contentMode, options: options) { (image, result) in
            complete?(image, result)
        }
    }
    
    /// 同步方法，同步得到的图片都是原始图片
    public func requestSyncImage(targetSize: AssetSize, contentMode: PHImageContentMode = .aspectFill, options: PHImageRequestOptions? = nil) -> UIImage? {
        var o = options
        if o == nil {
            o = PHImageRequestOptions()
        }
        o?.isSynchronous = true
        o?.isNetworkAccessAllowed = false
        
        var assetSize: CGSize = .zero
        switch targetSize {
        case .original:
            assetSize = CGSize(width: pixelWidth, height: pixelHeight)
        case .custom(let size):
            assetSize = size
        }
        
        var temp: UIImage? = nil
        PHCachingImageManager.default().requestImage(for: self, targetSize: assetSize, contentMode: contentMode, options: o) { (image, _) in
            temp = image
        }
        return temp
    }
    
}

public extension Array where Element == PHAsset {
    
    /// 获取PHAsset列表的时候，采用了同步的方式
    public func requestImages(targetSize: AssetSize, contentMode: PHImageContentMode = .default, options: PHImageRequestOptions? = nil) -> [UIImage] {
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

extension UIColor {
    
    convenience init(hex: Int, transparency: CGFloat = 1) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff, transparency: transparency)
    }
    
    convenience init(hexString: String, transparency: CGFloat = 1) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string =  hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }
        
        if string.characters.count == 3 {
            var str = ""
            string.characters.forEach { str.append(String($0) + String($0)) }
            string = str
        }
        
        self.init(hex: Int(string, radix: 16)!, transparency: transparency)
    }
    
    convenience init(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: transparency)
    }
    
}

private var kTransitionKey: Void?

// MARK: - Methods
extension UIViewController {
    
    var transition: TransitionDelegate {
        get {
            return objc_getAssociatedObject(self, &kTransitionKey) as! TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &kTransitionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func present(_ control: UIViewController, in present: MainAnimator? = nil, out dismiss: MainAnimator? = nil) {
        let interactive = JSDismissInteractiveTransition(from: (control as! JSPreviewController), to: (self as! JSPhotoViewController))
        let delegate = TransitionDelegate(in: present, out: dismiss, interactive: interactive)
        control.transition = delegate
        control.transitioningDelegate = delegate
        control.modalPresentationStyle = .custom
        self.present(control, animated: true, completion: nil)
    }
    
    func push(_ control: UIViewController, in push: MainAnimator? = nil, out pop: MainAnimator? = nil) {
        guard let naviControl = self.navigationController else { return }
        let delegate = TransitionDelegate(in: push, out: pop)
        naviControl.delegate = delegate
        naviControl.pushViewController(control, animated: true)
    }
    
}

extension UINavigationController {
    
    var top: UIViewController? {
        get {
            let top = viewControllers.count - 1
            guard top >= 0 else { return nil }
            return viewControllers[top]
        }
    }
    
}

extension UIView {
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
}

extension UIImage {
    
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(cgImage: image.cgImage!)
    }
    
}
