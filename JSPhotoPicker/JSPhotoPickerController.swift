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
    
    lazy var photoControl: JSPhotoViewController = {
        let photoControl = JSPhotoViewController()
        return photoControl
    }()
    
    deinit {
        print("\(self.classForCoder.description())销毁")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            setViewControllers([photoControl], animated: false)
        }
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

}
