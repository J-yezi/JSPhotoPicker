//
//  ParallexAnimator.swift
//  AnimatedCollectionViewLayout
//
//  Created by Jin Wang on 8/2/17.
//  Copyright © 2017 Uthoft. All rights reserved.
//

import UIKit

public struct ParallaxAttributesAnimator {
    
    public var speed: CGFloat
    public init(speed: CGFloat = 0.2) {
        self.speed = speed
    }
    
    public func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes) {
        let position = attributes.middleOffset
        let direction = attributes.scrollDirection
        
        guard let contentView = attributes.contentView else { return }
        
        if abs(position) >= 1 {
            contentView.frame = attributes.bounds
        } else if direction == .horizontal {
            let width = collectionView.frame.width
            let transitionX = -(width * speed * position)
            let transform = CGAffineTransform(translationX: transitionX, y: 0)
            let newFrame = attributes.bounds.applying(transform)
            contentView.frame = newFrame
        } else {
            let height = collectionView.frame.height
            let transitionY = -(height * speed * position)
            let transform = CGAffineTransform(translationX: 0, y: transitionY)
            let newFrame = attributes.bounds.applying(transform)
            contentView.frame = newFrame
        }
    }
}
