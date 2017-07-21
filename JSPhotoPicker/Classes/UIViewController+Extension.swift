//
//  UIVIewController+Extension.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/22/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

public extension UIViewController {

    public func presentImagePickerController(picker: JSPhotoPickerController) {
        JSPhotoPickerController.authorize { authorized in
            guard authorized == true else { return }
            self.present(picker, animated: true, completion: nil)
        }
    }

}
