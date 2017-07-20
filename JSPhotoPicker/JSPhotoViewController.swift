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
    fileprivate var middleView: UIButton!
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
        let fetchOptions = PHFetchOptions()
        // 所有照片
        let allPhotoResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions)
        // 自拍
        let selfResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: fetchOptions)
        // 连拍
        let burstResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumBursts, options: fetchOptions)
        // 截屏
        let screenshotResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: fetchOptions)
        // 视频
        let videoResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: fetchOptions)
        // 其他相册
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        var all = [JSAlbumModel]()
        for fetch in [allPhotoResult, selfResult, burstResult, screenshotResult, videoResult, albumResult] {
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
        print("\(self.classForCoder.description())销毁")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        PHPhotoLibrary.shared().register(self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        middleView = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
        middleView.setTitleColor(UIColor.black, for: .normal)
        middleView.addTarget(self, action: #selector(chooseAlbum), for: .touchUpInside)
        navigationItem.titleView = middleView
        
        if albums.count > 0 {
            reloadDataSource(index: selectAlbum)
        }
    }
    
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
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 7, options: [.curveEaseInOut], animations: {
                self.albumView?.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - self.topLayoutGuide.length)
            }, completion: nil)
        }
    }
    
    func hideAlbum() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseIn], animations: {
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
        
        let control = JSPreviewController()
        control.photos = self.photos
        control.currentIndex = indexPath.row
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(control, animated: true)
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
