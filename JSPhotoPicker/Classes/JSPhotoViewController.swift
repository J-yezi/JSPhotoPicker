//
//  JSPhotoViewController.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/22/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

struct PhotoResult {
    var indexPath: IndexPath
    var asset: PHAsset
}

/// 选择的图片集合
var selectAssets = Array<PhotoResult>()

class JSPhotoViewController: UIViewController {
    
    // MARK: - Data
    
    /// 提示信息控件的约束
    fileprivate var blurConstraint: NSLayoutConstraint!
    fileprivate var notiConstraint: NSLayoutConstraint!
    fileprivate var choosedImage: UIImage!
    fileprivate var arrowUpImage: UIImage!
    fileprivate var arrowDownImage: UIImage!
    fileprivate var complete: (([PHAsset]) ->Void)?
    fileprivate var cancel: (() -> Void)?
    fileprivate var config: JSPhotoPickerConfig!
    fileprivate let identifier = "JSPhotoCellIdentifier"
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
    
    /// 转场时候点击的cell
    var selectIndexPath: IndexPath!
    
    // MARK: - UI
    
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
    fileprivate lazy var notiLabel: UILabel = {
        let notiLabel: UILabel = UILabel()
        notiLabel.font = UIFont.systemFont(ofSize: 12)
        notiLabel.textAlignment = .center
        notiLabel.translatesAutoresizingMaskIntoConstraints = false
        return notiLabel
    }()
    fileprivate lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView()
        blurView.effect = UIBlurEffect(style: .extraLight)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    // MARK: - Lifecycle
    
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
        NotificationCenter.default.removeObserver(self)
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSet()
        
        /// 预览大图的时候选择了图片的通知
        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoose(notification:)), name: NSNotification.Name(rawValue: kChooseImageNotification), object: nil)
        
        PHPhotoLibrary.shared().register(self)
        if albums.count > 0 {
            reloadDataSource(index: currentAlbum)
        }
        
        /// 注册3DTouch
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        albumView?.frame = CGRect(x: 0, y: topLayoutGuide.length, width: kScreenWidth, height: kScreenHeight - topLayoutGuide.length)
    }
}

extension JSPhotoViewController {
    
    fileprivate func uiSet() {
        view.addSubview(collectionView)
        view.addSubview(blurView)
        view.addSubview(notiLabel)
        
        /// 显示最大图片选择的提示视图添加autolayout
        blurConstraint = NSLayoutConstraint(item: blurView, attribute: .bottom, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20))
        view.addConstraint(blurConstraint)
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: blurView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        
        notiConstraint = NSLayoutConstraint(item: notiLabel, attribute: .bottom, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(NSLayoutConstraint(item: notiLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 20))
        view.addConstraint(notiConstraint)
        view.addConstraint(NSLayoutConstraint(item: notiLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: notiLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
        
        let itemSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        itemSpace.width = -6
        navigationItem.leftBarButtonItems = [itemSpace, UIBarButtonItem(customView: leftBtn)]
        navigationItem.rightBarButtonItems = [itemSpace, UIBarButtonItem(customView: rightBtn)]
        navigationItem.titleView = middleView
    }
    
    /// 载入指定相册的照片
    fileprivate func reloadDataSource(index: Int) {
        guard index < albums.count else { return }
        middleView.setTitle(albums[index].title, for: .normal)
        collectionView.reloadData()
    }
    
    @objc fileprivate func imageCancel() {
        cancel?()
    }
    
    @objc fileprivate func imageDone() {
        complete?(selectAssets.map { return $0.asset })
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
        notiLabel.text = msg
        delayItem?.cancel()
        delayItem = DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            self.blurConstraint.constant = 0
            self.notiConstraint.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: delayItem!)
        blurConstraint.constant = 20
        notiConstraint.constant = 20
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc fileprivate func notificationChoose(notification: Notification) {
        let index = notification.object as! Int
        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? JSPhotoCell {
            cell.choosed = !cell.choosed
        }
    }
    
}

extension JSPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard currentAlbum < albums.count else { return 0 }
        return albums[currentAlbum].photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        PHCachingImageManager.default().cancelImageRequest(PHImageRequestID(cell.tag))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JSPhotoCell
        /// cell的indexPath稍微处理一下，当前相册的编号为section
        cell.data = JSPhotoCellData(choosedImage: choosedImage, indexPath: IndexPath(row: indexPath.row, section: currentAlbum), delegate: self, iCloudColor: config.selectColor)
        cell.imageView.image = nil
        
        let asset = albums[currentAlbum].photos[indexPath.row]
        PHCachingImageManager.default().requestImageData(for: asset, options: nil) { [weak cell, weak self] (data, _, _, _) in
            guard let cell = cell, let `self` = self else { return }
            /// 这个方法直接获取图片的原图数据，如果获取不到就表示iCloud上面的
            if data != nil {
                /// 判断是否被选中
                selectAssets.forEach {
                    cell.choosed = cell.data.indexPath == $0.indexPath
                }

                cell.showiCloud(false)

                /// 这个时候是获取的本地相册的数据，并不是iCloud上面的，但是这个方法比较怪异，如果是获取iCloud上面的照片，并且是自定义size不是图片的原始尺寸，即使设置了不使用网络，但是一样会通过网络获取
                let size = CGSize(width: self.imageCacheWidth, height: self.imageCacheWidth)
                cell.tag = Int(asset.requestImage(targetSize: .custom(size: size)) { (image, result) in
                    if let image = image {
                        cell.imageView.image = image
                    }
                })
            }else {
                /// iCloud上面照片的处理
                cell.showiCloud(true)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectIndexPath = indexPath
        self.present(JSPreviewController(config: self.config, photos: self.albums[self.currentAlbum].photos, index: indexPath.row, delegate: self), in: JSPresentAnimator(), out: JSDismissAnimator())
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
            selectAssets.append(PhotoResult(indexPath: cell.data.indexPath, asset: albums[currentAlbum].photos[cell.data.indexPath.row]))
        }else {
            selectAssets = selectAssets.filter { $0.indexPath != cell.data.indexPath }
        }
        rightBtn.setTitle(selectAssets.count > 0 ? "完成(\(selectAssets.count))" : "完成", for: .normal)
    }
    
    /// 从iCloud上面下载图片
    func iCloudDownLoad(row: Int) {
        let alert = UIAlertController(title: "提示", message: "是否需要从iCloud下载图片", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "是", style: .default) { _ in
            let asset = self.albums[self.currentAlbum].photos[row]
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = false
            options.progressHandler = { [weak self] (progress, _, _, _) in
                guard let `self` = self, let cell = self.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? JSPhotoCell else { return }
                DispatchQueue.main.async {
                    cell.iCloudView?.progress = progress
                }
            }
            asset.requestImage(targetSize: .custom(size: CGSize(width: 500, height: 500)), options: options)
        })
        UIApplication.shared.presentedController?.present(alert, animated: true, completion: nil)
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
            
            imageCacheWidth = collectionViewFlowLayout.itemSize.width * UIScreen.main.scale
        }
    }
}

extension JSPhotoViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            let albumModel = self.albums[self.currentAlbum]
            if let photosChanges = changeInstance.changeDetails(for: albumModel.photos) {
                if photosChanges.hasIncrementalChanges {
                    if let set = photosChanges.changedIndexes {
                        /// 目前的情况是出现iCloud下载完成后会执行
                        let indexPaths = set.map({ (index) -> IndexPath in
                            return IndexPath(row: index, section: 0)
                        })
                        self.collectionView.reloadItems(at: indexPaths)
                    }else {
                        /// 添加了新的照片
                        self.albums[self.currentAlbum].setPhotos(photos: photosChanges.fetchResultAfterChanges)
                        self.reloadDataSource(index: self.currentAlbum)
                        
                    }
                }
            }
        }
    }
    
}

@available(iOS 9.0, *)
extension JSPhotoViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView.indexPathForItem(at: view.convert(location, to: collectionView)), let cell = collectionView.cellForItem(at: indexPath) else { return nil }
    
        previewingContext.sourceRect = view.convert(cell.frame, from: collectionView)
        return JSPreviewController(config: config, photos: albums[currentAlbum].photos, index: indexPath.row, delegate: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

extension JSPhotoViewController: JSPreviewControllerDelegate {
    
    func changeViewerImage(old: Int, new: Int) {
        if let oldCell = collectionView.cellForItem(at: IndexPath(row: old, section: 0)) {
            oldCell.isHidden = false
        }
        if let newCell = collectionView.cellForItem(at: IndexPath(row: new, section: 0)) {
            newCell.isHidden = true
        }
    }
    
}

extension JSPhotoViewController: JSTransition {
    
    func animationRect(index: Int) -> CGRect {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0))!
        return collectionView.convert(cell.frame, to: view)
    }
    
    func animationView(index: Int) -> UIView? {
        return collectionView.cellForItem(at: IndexPath(row: index, section: 0))
    }
    
    func animationImage(index: Int) -> UIImage? {
        return albums[currentAlbum].photos[index].requestSyncImage(targetSize: .original)
    }
    
    func animationSize(index: Int) -> CGSize {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as! JSPhotoCell
        if let image = cell.imageView.image {
            return image.size
        }else {
            return UIScreen.main.bounds.size
        }
    }
    
}
