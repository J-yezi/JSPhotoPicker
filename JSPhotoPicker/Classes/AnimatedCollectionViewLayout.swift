//
//  AnimatedCollectionViewLayout.swift
//  AnimatedCollectionViewLayout
//
//  Created by jesse on 2/13/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class AnimatedCollectionViewLayout: UICollectionViewFlowLayout {
    
    public var animator: ParallaxAttributesAnimator = ParallaxAttributesAnimator()
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    override func prepare() {
        super.prepare()
        
    }
    
    public override class var layoutAttributesClass: AnyClass {
        return AnimatedCollectionViewLayoutAttributes.self
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        return attributes.map {
            self.transformLayoutAttributes($0.copy() as! AnimatedCollectionViewLayoutAttributes)
        }
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView else { return attributes }
        /// item在屏幕中间middleOffset为0，item从左侧刚好厉害屏幕middleOffset为-1，item刚好要从右边屏幕进入middleOffset为1
        
        var distance: CGFloat = 0
        var itemOffset: CGFloat = 0
        
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = attributes.center.x - collectionView.contentOffset.x
            attributes.startOffset = (attributes.frame.origin.x - collectionView.contentOffset.x) / attributes.frame.width
            attributes.endOffset = (attributes.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width) / attributes.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = attributes.center.y - collectionView.contentOffset.y
            attributes.startOffset = (attributes.frame.origin.y - collectionView.contentOffset.y) / attributes.frame.height
            attributes.endOffset = (attributes.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height) / attributes.frame.height
        }
        
        attributes.middleOffset = itemOffset / distance - 0.5
        attributes.scrollDirection = scrollDirection
        if attributes.contentView == nil {
            attributes.contentView = collectionView.cellForItem(at: attributes.indexPath)?.contentView
        }
        
        animator.animate(collectionView: collectionView, attributes: attributes)
        return attributes
    }

}

public class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionViewScrollDirection = .horizontal
    public var startOffset: CGFloat = 0
    public var middleOffset: CGFloat = 0
    public var endOffset: CGFloat = 0
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedCollectionViewLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
}
