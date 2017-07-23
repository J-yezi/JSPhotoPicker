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

public class JSPhotoPickerController: UINavigationController {
    fileprivate var complete: (([PHAsset], JSPhotoPickerController) ->Void)?
    fileprivate var cancel: ((JSPhotoPickerController) -> Void)?
    fileprivate var photoControl: JSPhotoViewController!
    
    public init(config: JSPhotoPickerConfig = JSPhotoPickerConfig()) {
        super.init(nibName: nil, bundle: nil)
        photoControl = JSPhotoViewController(config: config,
                 complete: { [weak self] assets in
                    guard let `self` = self else { return }
                    self.complete?(assets, self)
                 }, cancel: { [weak self] assets in
                    guard let `self` = self else { return }
                    self.cancel?(self)
                 })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photoControl], animated: false)
        }
    }
}

public extension JSPhotoPickerController {
    fileprivate func uiSet() {
        view.backgroundColor = UIColor.white
    }
    
    class func authorize(_ complete: @escaping (Bool) -> Void) {
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
    
    public func display(_ complete: (([PHAsset], JSPhotoPickerController) -> Void)?, cancel: ((JSPhotoPickerController) -> Void)?) {
        JSPhotoPickerController.authorize { [unowned self] in
            guard $0 == true else { return }
            self.complete = complete
            self.cancel = cancel
            UIApplication.shared.presentedController?.present(self, animated: true, completion: nil)
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
