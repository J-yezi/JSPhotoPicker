
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
    
    public init(maxNumber: Int = 1) {
        self.maxNumber = maxNumber
    }
}
