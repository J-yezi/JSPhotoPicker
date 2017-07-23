//
//  ViewController.swift
//  Example
//
//  Created by jesse on 2017/7/20.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit
import JSPhotoPicker
import BSImagePicker
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var a: UIView!
    var b: Bool = false
    var delayItem: DispatchWorkItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        a = UIView(frame: CGRect(x: 0, y: 400, width: 100, height: 100))
        a.backgroundColor = UIColor.green
        view.addSubview(a)
    }

    @IBAction func click(_ sender: Any) {
        
        let control = JSPhotoPickerController(config: JSPhotoPickerConfig(maxNumber: 3))
        control.display({ [weak self] assets, picker in
            guard let `self` = self else { return }
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            let asset = assets.first!
            
            
            asset.requestImage(targetSize: .custom(size: CGSize(width: 150, height: 150)), contentMode: .aspectFit, options: options, isSynchronous: true, complete: { image in
                self.imageView.image = image
                print("--------\(image!.scale) - \(image!.size)")
            })
            print("-------aaaaaaa")
            picker.dismiss(animated: true, completion: nil)
        }) { picker in
            picker.dismiss(animated: true, completion: nil)
        }
    }


}
