//
//  JSConstant.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/7/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

let defaultColor: UIColor = UIColor(red: 236, green: 236, blue: 236)
let bundle: Bundle = Bundle(path: Bundle(for: JSPhotoPickerController.self).path(forResource: "JSPhotoPicker", ofType: "bundle")!)!
let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height
let kLog: Bool = true

let kChooseImageNotification: String = "kChooseImageNotification"

func Image(named: String) -> UIImage? {
    return UIImage(named: named, in: bundle, compatibleWith: nil)
}

/// 计算图片的size适配了屏幕后的rect
func adaptationRect(size: CGSize) -> CGRect {
    var rect: CGRect = .zero
    let height = UIScreen.main.bounds.width / size.width * size.height
    rect.size = CGSize(width: UIScreen.main.bounds.width, height: height)
    var origin = CGPoint.zero
    if rect.height < UIScreen.main.bounds.height {
        origin.y = (UIScreen.main.bounds.height - rect.height) / 2
    }
    rect.origin = origin
    return rect
}
