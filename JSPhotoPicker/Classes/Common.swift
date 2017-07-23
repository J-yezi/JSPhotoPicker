//
//  JSConstant.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/7/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

let bundle: Bundle = Bundle(path: Bundle(for: JSPhotoPickerController.self).path(forResource: "JSPhotoPicker", ofType: "bundle")!)!

func Image(named: String) -> UIImage? {
    return UIImage(named: named, in: bundle, compatibleWith: nil)
}

func calculateImagePreviewRect(_ imageSize: CGSize) -> CGRect {
    let height = floor(imageSize.height / imageSize.width * kScreenWidth)
    if height > kScreenHeight {
        return CGRect(x: 0, y: 0, width: kScreenWidth, height: height)
    }else {
        return CGRect(x: 0, y: (kScreenHeight - height) / 2, width: kScreenWidth, height: height)
    }
}
