//
//  JSAlbumView.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/22/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit
import Photos

class JSAlbumView: UIView {
    fileprivate let identifier = "JSAlbumViewCell"
    fileprivate let albums: [JSAlbumModel]
    fileprivate var selectBlock: ((Int) -> Void)
    fileprivate var closeBlock: (() -> Void)?
    fileprivate lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        tableView.register(JSAlbumCell.self, forCellReuseIdentifier: self.identifier)
        return tableView
    }()
    
    init(frame: CGRect, albums: [JSAlbumModel], choose: @escaping ((Int) -> Void), close: @escaping (() -> Void)) {
        self.albums = albums
        self.selectBlock = choose
        self.closeBlock = close
        super.init(frame: frame)
        uiSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if kLog {
            print("\(self.classForCoder.description()) - deinit")
        }
    }
}

extension JSAlbumView {
    fileprivate func uiSet() {
        backgroundColor = UIColor.white
        addSubview(tableView)
    }
}

extension JSAlbumView: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < -70 {
//            closeBlock?()
//        }
//        print(scrollView.contentOffset.y)
//        if scrollView.contentOffset.y <= 0 && scrollView.isDragging {
//            print("------------------\(scrollView.isDragging)")
//            transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
//            tableView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
//        }else {
//            transform = CGAffineTransform.identity
//            tableView.transform = CGAffineTransform.identity
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! JSAlbumCell
        let album = albums[indexPath.row]
        cell.titleLabel.text = album.title
        cell.countLabel.text = "\(album.count)"
        
        album.photos.enumerateObjects({ (asset, index, stop) in
            JSImageManager.getPhoto(asset: asset, width: 74, complete: { (image, result) in
                cell.albumImageView.image = image
            })
            stop.initialize(to: true)
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectBlock(indexPath.row)
    }
}
