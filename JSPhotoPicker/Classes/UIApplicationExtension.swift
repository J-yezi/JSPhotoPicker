//
//  UIApplicationExtension.swift
//  BSGridCollectionViewLayout
//
//  Created by jesse on 2017/7/23.
//

import UIKit

private var kStatusViewKey: Void?
private var kFullViewKey: Void?

//MARK: - Properties
public extension UIApplication {
    /// 获取整个应用被present道最顶部的controller，方便后面使用该controller进行present
    public var presentedController: UIViewController? {
        if let control = UIApplication.shared.keyWindow?.rootViewController {
            while control.presentedViewController != nil && control.presentedViewController?.isBeingDismissed == false {
                return control.presentedViewController!
            }
            return control
        }
        return nil
    }
    
    /// statusView.isHidden = false来打开这个遮挡状态栏的视图，默认是false
    public var statusView: UIView? {
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
