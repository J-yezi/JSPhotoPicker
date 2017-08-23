//
//  ViewController.swift
//  Example
//
//  Created by jesse on 2017/7/20.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit
import JSPhotoPicker
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Thread.main.name = "Main Thread"
    }

    @IBAction func click(_ sender: Any) {
        let isCompress: Bool = false
        
        JSPhotoPickerController(complete: {
            let option = PHImageRequestOptions()
            option.resizeMode = .exact
            let image = $0.1.first!.requestSyncImage(targetSize: .custom(size: CGSize(width: 1500, height: 1500)), options: option)
            
//            let data = UIImageJPEGRepresentation(image!, 0.6)
//            self.imageView.image = UIImage(data: data!)
//            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
//
//            self.imageView.image = image
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
            
            if isCompress {

            }else {

            }
            
            
            print(self.imageView.image!.size)
            $0.0.dismiss(animated: true, completion: nil)
        }, cancel: {
            $0.dismiss(animated: true, completion: nil)
        }).display()
    }

}
