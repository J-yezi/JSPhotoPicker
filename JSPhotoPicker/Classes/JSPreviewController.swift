//
//  JSPreviewController.swift
//  JSPhotoPicker
//
//  Created by jesse on 2/4/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

public protocol JSPreviewControllerDelegate: class {
    /// 设置最初始状态的图片，可以自己提供小图
    func placeholderImage(_ index: Int) -> UIImage?
    /// 点击时候图片的位置或者退出浏览器后图片的位置
    func animationRect(index: Int) -> CGRect?
    /// 点击时候图片的size
    func animationSize(index: Int) -> CGSize?
    /// 浏览器切换的时候触发，并且如果出现切换的item并没有显示，这个时候可以在这个方法控制contentOffset的变化
    func changeViewerImage(old: Int, new: Int)
    /// 图片浏览器即将推出，进入或退出动画执行之前
    func viewerWillAnimation(index: Int, isAppear: Bool)
    /// 图片浏览器完全进入或退出，当下载好了大图的时候，这个大图是带回去了
    func viewerDidAnimation(index: Int, isAppear: Bool, image: UIImage?)
}

/// 因为现在默认是实现了这些方法都表明这些方法是可选的
extension JSPreviewControllerDelegate {
    func animationRect(index: Int) -> CGRect? { return nil }
    func animationSize(index: Int) -> CGSize? { return nil }
    func placeholderImage(_ index: Int) -> UIImage? { return nil }
    func changeViewerImage(old: Int, new: Int) {}
    func viewerWillAnimation(index: Int, isAppear: Bool) {}
    func viewerDidAnimation(index: Int, isAppear: Bool, image: UIImage?) {}
}

class JSPreviewController: UIViewController {
    
    // MARK: - Data
    
    fileprivate var choosedImage: UIImage!
    fileprivate var config: JSPhotoPickerConfig!
    fileprivate let identifier = "JSPreviewCellIdentifier"
    fileprivate var imageView: UIImageView!
    fileprivate var photos: PHFetchResult<PHAsset>!
    fileprivate var delayItem: DispatchWorkItem?
    /// 状态栏是否隐藏
    fileprivate var isHidden: Bool = false
    /// cell之间的间距
    fileprivate let space: CGFloat = 10
    /// 总页数
    fileprivate var totalPage: Int = 0
    /// 当前页
    fileprivate(set) var currentPage: Int = -1 {
        didSet {
            if currentPage != oldValue {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? JSPreviewCell else { return }
                changeScrollView?(cell.scrollView)
                delegate?.changeViewerImage(old: oldValue, new: currentPage)
            }
        }
    }
    fileprivate weak var delegate: JSPreviewControllerDelegate?
    
    // MARK: - 转场手势动画使用
    
    var changeScrollView: ((UIScrollView) -> Void)?
    
    // MARK: - UI
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = AnimatedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = self.space
        layout.itemSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: self.space / 2, bottom: 0, right: self.space / 2)
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: -self.space / 2, y: 0, width: self.view.bounds.width + self.space, height: self.view.bounds.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentOffset = CGPoint(x: CGFloat(self.currentPage) * collectionView.bounds.width, y: 0)
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
    fileprivate lazy var notiLabel: UILabel = {
        let notiLabel: UILabel = UILabel(frame: CGRect(x: 0, y: -20, width: kScreenWidth, height: 20))
        notiLabel.font = UIFont.systemFont(ofSize: 12)
        notiLabel.textAlignment = .center
        notiLabel.translatesAutoresizingMaskIntoConstraints = false
        return notiLabel
    }()
    fileprivate lazy var blurView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(frame: CGRect(x: 0, y: -20, width: kScreenWidth, height: 20))
        blurView.effect = UIBlurEffect(style: .extraLight)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    
    init(config: JSPhotoPickerConfig, photos: PHFetchResult<PHAsset>, index: Int, delegate: JSPreviewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.delegate = delegate
        self.currentPage = index
        self.config = config
        
        /// 因为图片需要渲染或者叠加操作，所以直接就统一在这里一次生成好
        choosedImage = Image(named: "image_choose_confirm")!.combine(Image(named: "image_choose_bg")!.tint(config.selectColor)!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        uiSet()
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        /// 第一次传递手势
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? JSPreviewCell else { return }
        changeScrollView?(cell.scrollView)
    }
    
    func addCrop() {
        let cropView = JSPreviewCropView(frame: view.bounds, cropType: .circle)
        view.addSubview(cropView)
    }

}

extension JSPreviewController {
    
    fileprivate func uiSet() {
        view.backgroundColor = UIColor.clear
        view.addSubview(collectionView)
        view.addSubview(blurView)
        view.addSubview(notiLabel)
    }
    
    /// 选择超出最大值的提示
    fileprivate func display(msg: String) {
        notiLabel.text = msg
        delayItem?.cancel()
        delayItem = DispatchWorkItem(block: { [weak self] in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.4, animations: {
                self.blurView.y = -20
                self.notiLabel.y = -20
            })
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: delayItem!)
        UIView.animate(withDuration: 0.4, animations: {
            self.blurView.y = 0
            self.notiLabel.y = 0
        })
    }
    
}

extension JSPreviewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JSPreviewCell
        cell.data = JSPreviewCellData(choosedImage: choosedImage, indexPath: indexPath, iCloudColor: config.selectColor, delegate: self)
        cell.asset = photos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! JSPreviewCell).scrollView.zoomScale = 1
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

extension JSPreviewController: JSTransition {
    
    func animationView(index: Int) -> UIView? {
        let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0))!
        return cell
    }
    
    func animationImage(index: Int) -> UIImage? {
        return photos[currentPage].requestSyncImage(targetSize: .original)
    }
    
    func animationRect(index: Int) -> CGRect {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as! JSPreviewCell
        return cell.imageView.frame
    }
    
}

extension JSPreviewController: JSPreviewCellDelegate {
    
    func closeDisplay(cell: JSPreviewCell) {
        dismiss(animated: true, completion: nil)
    }
    
    func chooseImage(cell: JSPreviewCell) {
        /// 如果是已经达到最大选择就提示
        if !cell.choosed && config.maxNumber == selectAssets.count {
            display(msg: "图片最多选择\(config.maxNumber)张")
            return
        }
        
        cell.choosed = !cell.choosed
        if cell.choosed {
            selectAssets.append(PhotoResult(indexPath: cell.data.indexPath, asset: photos[cell.data.indexPath.row]))
        }else {
            selectAssets = selectAssets.filter { $0.indexPath != cell.data.indexPath }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kChooseImageNotification), object: currentPage)
    }
    
}
