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
    
    fileprivate let identifier = "JSPreviewCellIdentifier"
    fileprivate var imageView: UIImageView!
    fileprivate var currentIndex: Int = 0
    fileprivate var photos: PHFetchResult<PHAsset>!
    /// 状态栏是否隐藏
    fileprivate var isHidden: Bool = false
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset = CGPoint(x: CGFloat(self.currentIndex) * collectionView.bounds.width, y: 0)
        collectionView.register(JSPreviewCell.self, forCellWithReuseIdentifier: self.identifier)
        return collectionView
    }()
    @available(iOS 9.0, *)
    fileprivate lazy var previewActions: [UIPreviewActionItem] = {
        func previewActionWithTitle(_ title: String, style: UIPreviewActionStyle = .default) -> UIPreviewAction {
            return UIPreviewAction(title: title, style: style) { (previewAction, viewController) -> Void in
                NSLog("\(previewAction.title)")
            }
        }
        return [previewActionWithTitle("选择")]
    }()
    
    init(photos: PHFetchResult<PHAsset>, index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.currentIndex = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.isNavigationBarHidden = true
        
        uiSet()
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

extension JSPreviewController {
    fileprivate func uiSet() {
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        view.clipsToBounds = true
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
    
    @available(iOS 9.0, *)
    override var previewActionItems: [UIPreviewActionItem] {
        return self.previewActions
    }
}
