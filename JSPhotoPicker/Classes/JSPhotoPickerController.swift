//
//  JSPhotoPickerController.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/22/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height
let kLog: Bool = true

public class JSPhotoPickerController: UINavigationController {
    fileprivate var complete: ((JSPhotoPickerController, [PHAsset]) ->Void)?
    fileprivate var cancel: ((JSPhotoPickerController) -> Void)?
    fileprivate var photoControl: JSPhotoViewController!
    /// 在用户授权相册时候，是一个异步过程，所有会出现deinit的情况，所有需要一个循环引用
    fileprivate var strong: AnyObject?
    
    public init(config: JSPhotoPickerConfig = JSPhotoPickerConfig(), complete: ((JSPhotoPickerController, [PHAsset]) ->Void)? = nil, cancel: ((JSPhotoPickerController) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.complete = complete
        self.cancel = cancel
        photoControl = JSPhotoViewController(config: config,
                                             complete: { [weak self] assets in
                                                guard let `self` = self else { return }
                                                self.strong = nil
                                                self.complete?(self, assets)
            }, cancel: { [weak self] assets in
                guard let `self` = self else { return }
                self.strong = nil
                self.cancel?(self)
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photoControl], animated: false)
        }
    }
}

extension JSPhotoPickerController {
    fileprivate func uiSet() {
        view.backgroundColor = UIColor.white
    }
    
    class public func authorize(_ complete: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            complete(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.authorize(complete)
            })
        default:
            complete(false)
        }
    }
    
    public func display() {
        strong = self
        JSPhotoPickerController.authorize { [weak self] in
            guard $0 == true, let `self` = self else { return }
            DispatchQueue.main.async {
                UIApplication.shared.presentedController?.present(self, animated: true, completion: nil)
            }
        }
    }
}

/// 设置图片选择器不可进行旋转
extension JSPhotoPickerController {
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
