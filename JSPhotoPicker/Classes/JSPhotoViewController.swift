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
    fileprivate var choosedImage: UIImage!
    fileprivate var arrowUpImage: UIImage!
    fileprivate var arrowDownImage: UIImage!
    fileprivate var complete: (([PHAsset]) ->Void)?
    fileprivate var cancel: (() -> Void)?
    fileprivate var config: JSPhotoPickerConfig!
    fileprivate let identifier = "JSPhotoCellIdentifier"
    fileprivate var photos: PHFetchResult<PHAsset>!
    fileprivate var imageCacheWidth: CGFloat = 0
    fileprivate var delayItem: DispatchWorkItem?
    fileprivate lazy var middleView: JSTitleButton = {
        let middleView = JSTitleButton(frame: CGRect(x: 0, y: 0, width: 150, height: 32))
        middleView.setTitleColor(UIColor.black, for: .normal)
        middleView.setImage(self.arrowDownImage, for: .normal)
        middleView.addTarget(self, action: #selector(chooseAlbum), for: .touchUpInside)
        return middleView
    }()
    fileprivate var albumView: JSAlbumView?
    fileprivate var currentAlbum = 0
    /// push时候控件的大小
    var pushRect = CGRect.zero
    /// push时候转场的控件
    var pushImage: UIImage!
    /// 选择的图片集合
    fileprivate var selectAssets = Array<(IndexPath, PHAsset)>()
    
    fileprivate lazy var leftBtn: UIButton = {
        let leftBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 32))
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.contentHorizontalAlignment = .left
        leftBtn.adjustsImageWhenHighlighted = false
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        leftBtn.setTitleColor(UIColor(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0), for: .normal)
        leftBtn.addTarget(self, action: #selector(imageCancel), for: .touchUpInside)
        return leftBtn
    }()
    fileprivate lazy var rightBtn: UIButton = {
        let rightBtn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 32))
        rightBtn.setTitle("完成", for: .normal)
        rightBtn.adjustsImageWhenHighlighted = false
        rightBtn.contentHorizontalAlignment = .right
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        rightBtn.setTitleColor(UIColor(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 1.0), for: .normal)
        rightBtn.addTarget(self, action: #selector(imageDone), for: .touchUpInside)
        return rightBtn
    }()
    fileprivate lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: JSPhotoViewFlowLayout())
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(JSPhotoCell.self, forCellWithReuseIdentifier: self.identifier)
        return collectionView
    }()
    /// 相册列表
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
    
    init(config: JSPhotoPickerConfig, complete: (([PHAsset]) -> Void)?, cancel: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.config = config
        self.complete = complete
        self.cancel = cancel
        
        /// 因为图片需要渲染或者叠加操作，所以直接就统一在这里一次生成好
        choosedImage = Image(named: "image_choose_confirm")!.combine(Image(named: "image_choose_bg")!.tint(config.selectColor)!)
        arrowUpImage = Image(named: "arrow_up")?.tint(config.selectColor)
        arrowDownImage = Image(named: "arrow_down")?.tint(config.selectColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        
        PHPhotoLibrary.shared().register(self)
        if albums.count > 0 {
            reloadDataSource(index: currentAlbum)
        }
        
        /// 注册3DTouch
//        if #available(iOS 9.0, *) {
//            if traitCollection.forceTouchCapability == .available {
//                registerForPreviewing(with: self, sourceView: view)
//            }
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        albumView?.frame = CGRect(x: 0, y: topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - topLayoutGuide.length)
    }
}

extension JSPhotoViewController {
    fileprivate func uiSet() {
        view.addSubview(collectionView)
        
        let itemSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        itemSpace.width = -6
        navigationItem.leftBarButtonItems = [itemSpace, UIBarButtonItem(customView: leftBtn)]
        navigationItem.rightBarButtonItems = [itemSpace, UIBarButtonItem(customView: rightBtn)]
        navigationItem.titleView = middleView
    }
    
    /// 载入指定相册的照片
    fileprivate func reloadDataSource(index: Int) {
        guard index < albums.count else { return }
        
        let model = albums[index]
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        photos = PHAsset.fetchAssets(in: model.album, options: fetchOptions)
        
        middleView.setTitle(model.title, for: .normal)
        
        collectionView.reloadData()
    }
    
    @objc fileprivate func imageCancel() {
        cancel?()
    }
    
    @objc fileprivate func imageDone() {
        complete?(selectAssets.map { return $0.1 })
    }
    
    @objc fileprivate func chooseAlbum() {
        if let _ = albumView {
            hideAlbum()
        }else {
            albumView = JSAlbumView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight - topLayoutGuide.length), albums: albums, choose: { [unowned self] index in
                self.currentAlbum = index
                self.hideAlbum()
                self.reloadDataSource(index: index)
                }, close: {
                    self.hideAlbum()
            })
            view.addSubview(albumView!)
            
            showAlbum()
        }
    }
    
    fileprivate func showAlbum() {
        middleView.setImage(arrowUpImage, for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 7, options: [.curveEaseInOut], animations: {
            self.albumView?.frame = CGRect(x: 0, y: self.topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - self.topLayoutGuide.length)
        }, completion: nil)
    }
    
    fileprivate func hideAlbum() {
        middleView.setImage(arrowDownImage, for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 7, options: [.curveEaseInOut], animations: {
            self.albumView?.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight - self.topLayoutGuide.length)
        }, completion: { (finish) in
            self.albumView?.removeFromSuperview()
            self.albumView = nil
        })
    }
    
    /// 选择超出最大值的提示
    fileprivate func display(msg: String) {
        if UIApplication.shared.statusView?.subviews.count == 0 {
            UIApplication.shared.statusView?.isHidden = false
            UIApplication.shared.statusView?.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.width, height: 20)
            
            let label = UILabel(frame: UIApplication.shared.statusView!.bounds)
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.backgroundColor = UIColor.white
            label.text = msg
            
            UIApplication.shared.statusView?.addSubview(label)
        }
        delayItem?.cancel()
        delayItem = DispatchWorkItem(block: {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
                UIApplication.shared.statusView?.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.width, height: 20)
            }) { _ in
                UIApplication.shared.statusView = nil
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: delayItem!)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
            UIApplication.shared.statusView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)
        })
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
        /// cell的indexPath稍微处理一下，当前相册的编号为section
        cell.indexPath = IndexPath(row: indexPath.row, section: currentAlbum)
        /// 判断是否被选中
        selectAssets.forEach {
            cell.choosed = cell.indexPath == $0.0
        }
        cell.choosedImage = choosedImage
        cell.delegate = self
        cell.tag = Int(JSImageManager.getPhoto(asset: photos[indexPath.row], width: imageCacheWidth, complete: { (image, _) in
            cell.imageView.image = image
        }))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! JSPhotoCell
//        pushRect = collectionView.convert(cell.frame, to: self.view)
//        pushImage = cell.imageView.image
//
//        let options = PHImageRequestOptions()
//        options.isSynchronous = true /// 同步
//        JSImageManager.getPhoto(asset: photos[indexPath.row], width: kScreenWidth, options: options) { [weak self] (image, _) in
//            self?.pushImage = image
//        }
//
//        self.navigationController?.delegate = self
//        self.navigationController?.pushViewController(JSPreviewController(photos: photos, index: indexPath.row), animated: true)
        
        /// 暂时不支持预览，后面再添加这个功能
        guard let cell = collectionView.cellForItem(at: indexPath) as? JSPhotoCell else { return }
        chooseImage(cell: cell)
    }
}

extension JSPhotoViewController: JSPhotoCellDelegate {
    func chooseImage(cell: JSPhotoCell) {
        /// 如果是已经达到最大选择就提示
        if !cell.choosed && config.maxNumber == selectAssets.count {
            display(msg: "图片最多选择\(config.maxNumber)张")
            return
        }
        
        cell.choosed = !cell.choosed
        if cell.choosed {
            selectAssets.append((cell.indexPath, photos[cell.indexPath.row]))
        }else {
            selectAssets = selectAssets.filter { $0.0 != cell.indexPath }
        }
        rightBtn.setTitle(selectAssets.count > 0 ? "完成(\(self.selectAssets.count))" : "完成", for: .normal)
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
    /// 这里主要是处理屏幕旋转
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
            let albumModel = self.albums[self.currentAlbum]
            if let photosChanges = changeInstance.changeDetails(for: albumModel.photos) {
                self.albums[self.currentAlbum].photos = photosChanges.fetchResultAfterChanges
                self.reloadDataSource(index: self.currentAlbum)
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
