
//
//  JSPhotoPickerConfig.swift
//  BSGridCollectionViewLayout
//
//  Created by jesse on 2017/7/23.
//

import UIKit

public struct JSPhotoPickerConfig {
    /// 最多选择好多张照片
    var maxNumber: Int
    
    /// 选择图片时候图标的颜色
    var selectColor: UIColor
    
    public init(maxNumber: Int = 1, selectColor: UIColor = UIColor(red: 21.0 / 255.0, green: 126.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)) {
        self.maxNumber = maxNumber
        self.selectColor = selectColor
    }
}
