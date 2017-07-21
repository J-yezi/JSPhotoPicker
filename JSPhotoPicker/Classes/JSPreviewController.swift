//
//  JSPreviewController.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSPreviewController: UIViewController {
    
    let identifier = "JSPreviewCellIdentifier"
    var imageView: UIImageView!
    var currentIndex: Int = 0
    var photos: PHFetchResult<PHAsset>!
    fileprivate var isHidden: Bool = false
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(JSPreviewCell.self, forCellWithReuseIdentifier: self.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.clipsToBounds = true
        automaticallyAdjustsScrollViewInsets = false
        
        collectionView.contentOffset = CGPoint(x: CGFloat(currentIndex) * collectionView.bounds.size.width, y: 0)
        
//        addCrop()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func hideNav() {
        guard let control = self.navigationController else { return }
        control.setNavigationBarHidden(!control.isNavigationBarHidden, animated: true)
        showAndHideStatus()
    }
    
    func addCrop() {
        let cropView = JSPreviewCropView(frame: view.bounds, cropType: .circle)
        view.addSubview(cropView)
    }

}

extension JSPreviewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JSPreviewCell
        cell.asset = photos[indexPath.row]
        cell.singleTapBlock = { [unowned self] in
            self.hideNav()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! JSPreviewCell).recoverScrollZoom()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! JSPreviewCell).recoverScrollZoom()
    }
    
}

extension JSPreviewController {
    
    func showAndHideStatus() {
        isHidden = !isHidden
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return isHidden
    }
    
}
