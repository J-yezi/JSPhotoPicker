//
//  JSAlbumCell.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/23/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import UIKit

class JSAlbumCell: UITableViewCell {
    lazy var albumImageView: UIImageView = {
        let albumImageView = UIImageView(frame: CGRect(x: 12, y: 8, width: 74, height: 74))
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        return albumImageView
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: 100, y: 24, width: 150, height: 20))
        titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 17)
        return titleLabel
    }()
    lazy var countLabel: UILabel = {
        let countLabel = UILabel(frame: CGRect(x: 100, y: 50, width: 150, height: 20))
        countLabel.font = UIFont(name: "PingFangSC-Regular", size: 15)
        return countLabel
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(colorLiteralRed: 240.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
        selectedBackgroundView = selectedView
        
        addSubview(albumImageView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self.classForCoder.description()) - deinit")
    }
}
