//
//  JSPhotoViewController.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/22/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSPhotoViewController: UIViewController {
    
    fileprivate let identifier = "JSPhotoCellIdentifier"
    fileprivate var photos: PHFetchResult<PHAsset>!
    fileprivate var imageCacheWidth: CGFloat = 0
    fileprivate lazy var middleView: UIButton = {
        let middleView = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
        middleView.setTitleColor(UIColor.black, for: .normal)
        middleView.addTarget(self, action: #selector(chooseAlbum), for: .touchUpInside)
        return middleView
    }()
    fileprivate var albumView: JSAlbumView?
    fileprivate var selectAlbum = 0
    var selectRect = CGRect.zero
    var selectImage: UIImage!
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: JSPhotoViewFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(JSPhotoCell.self, forCellWithReuseIdentifier: self.identifier)
        return collectionView
    }()
    fileprivate lazy var albums: [JSAlbumModel] = { () -> [JSAlbumModel] in
        var fetchs = [PHFetchResult<PHAssetCollection>]()
        let fetchOptions = PHFetchOptions()
        // 所有照片
        fetchs.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions))
        // 自拍
        if #available(iOS 9.0, *) {
            fetchs.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: fetchOptions))
        }
        // 连拍
        fetchs.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumBursts, options: fetchOptions))
        // 截屏
        if #available(iOS 9.0, *) {
            fetchs.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: fetchOptions))
        }
        // 视频
        fetchs.append(PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: fetchOptions))
        // 其他相册
        fetchs.append(PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions))
        
        var all = [JSAlbumModel]()
        for fetch in fetchs {
            for i in 0 ..< fetch.count {
                let model = JSAlbumModel(album: fetch[i])
                if model.count > 0 {
                    all.append(model)
                }
            }
        }
        
        return all
    }()
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        print("\(self.classForCoder.description()) - deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        
        PHPhotoLibrary.shared().register(self)
        if albums.count > 0 {
            reloadDataSource(index: selectAlbum)
        }
        
        /// 注册3DTouch
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }
    
    /// 载入指定相册的照片
    func reloadDataSource(index: Int) {
        guard index < albums.count else { return }
        
        let model = albums[index]
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        photos = PHAsset.fetchAssets(in: model.album, options: fetchOptions)
        
        middleView.setTitle(model.title, for: .normal)
        
        collectionView.reloadData()
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func done() {
        
    }
    
    func chooseAlbum() {
        if let _ = albumView {
            hideAlbum()
        }else {
            albumView = JSAlbumView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight - topLayoutGuide.length), albums: albums, choose: { [unowned self] index in
                self.selectAlbum = index
                self.hideAlbum()
                self.reloadDataSource(index: index)
                }, close: {
                    self.hideAlbum()
            })
            view.addSubview(albumView!)
            
            showAlbum()
        }
    }
    
    func showAlbum() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 7, options: [.curveEaseInOut], animations: {
            self.albumView?.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - self.topLayoutGuide.length)
        }, completion: nil)
    }
    
    func hideAlbum() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 7, options: [.curveEaseInOut], animations: {
            self.albumView?.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight - self.topLayoutGuide.length)
        }, completion: { (finish) in
            self.albumView?.removeFromSuperview()
            self.albumView = nil
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        albumView?.frame = CGRect(x: 0, y: topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - topLayoutGuide.length)
    }
}

extension JSPhotoViewController {
    fileprivate func uiSet() {
        view.addSubview(collectionView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.titleView = middleView
    }
}

extension JSPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        JSImageManager.cancelRequest(requestID: PHImageRequestID(cell.tag))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JSPhotoCell
        cell.asset = photos[indexPath.row]
        
        cell.tag = Int(JSImageManager.getPhoto(asset: photos[indexPath.row], width: imageCacheWidth, complete: { (image, _) in
            cell.imageView.image = image
        }))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! JSPhotoCell
        selectRect = collectionView.convert(cell.frame, to: self.view)
        selectImage = cell.imageView.image
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true /// 同步
        JSImageManager.getPhoto(asset: photos[indexPath.row], width: kScreenWidth, options: options) { [weak self] (image, _) in
            self?.selectImage = image
        }
        
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(JSPreviewController(photos: photos, index: indexPath.row), animated: true)
    }
}

extension JSPhotoViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if  operation == .push {
            return JSPreviewPushAnimator()
        }else {
            return nil
        }
    }
}

extension JSPhotoViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionView.collectionViewLayout as? JSPhotoViewFlowLayout {
            switch (traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass) {
            case (.compact, .regular): // iPhone5-6 portrait
                collectionViewFlowLayout.itemsPerRow = 3
            case (.compact, .compact): // iPhone5-6 landscape
                collectionViewFlowLayout.itemsPerRow = 5
            case (.regular, .regular): // iPad portrait/landscape
                collectionViewFlowLayout.itemsPerRow = 7
            default:
                collectionViewFlowLayout.itemsPerRow = 3
            }
            
            imageCacheWidth = collectionViewFlowLayout.itemSize.width
        }
    }
}

extension JSPhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            let albumModel = self.albums[self.selectAlbum]
            if let photosChanges = changeInstance.changeDetails(for: albumModel.photos) {
                self.albums[self.selectAlbum].photos = photosChanges.fetchResultAfterChanges
                self.reloadDataSource(index: self.selectAlbum)
            }
        }
    }
}

@available(iOS 9.0, *)
extension JSPhotoViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: view.convert(location, to: collectionView)), let cell = collectionView.cellForItem(at: indexPath) else { return nil }
    
        previewingContext.sourceRect = view.convert(cell.frame, from: collectionView)
        return JSPreviewController(photos: photos, index: indexPath.row)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
