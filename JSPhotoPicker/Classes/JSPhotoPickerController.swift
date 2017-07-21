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
    private lazy var photoControl: JSPhotoViewController = {
        let photoControl = JSPhotoViewController()
        return photoControl
    }()
    fileprivate var presentedController: UIViewController? {
        if let control = UIApplication.shared.keyWindow?.rootViewController {
            while control.presentedViewController != nil && control.presentedViewController?.isBeingDismissed == false {
                return control.presentedViewController!
            }
            return control
        }
        return nil
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photoControl], animated: false)
        }
    }
}

public extension JSPhotoPickerController {
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
    
    public func show() {
        JSPhotoPickerController.authorize { [unowned self] in
            guard $0 == true else { return }
            self.presentedController?.present(self, animated: true, completion: nil)
        }
    }
}
