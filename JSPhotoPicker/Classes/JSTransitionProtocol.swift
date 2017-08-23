//
//  JSTransitionProtocol.swift
//  PictureBrowser
//
//  Created by jesse on 2017/8/14.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit

protocol JSTransition {
    
    /// 位置
    func animationRect(index: Int) -> CGRect
    /// 转场动画的图片
    func animationImage(index: Int) -> UIImage?
    /// 转场点击的视图
    func animationView(index: Int) -> UIView?
    func animationSize(index: Int) -> CGSize
}

extension JSTransition {
    func animationSize(index: Int) -> CGSize { return UIScreen.main.bounds.size }
}
