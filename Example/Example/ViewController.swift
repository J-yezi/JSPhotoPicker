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
    var a: UIView!
    var b: Bool = false
    var delayItem: DispatchWorkItem!
//    var control: JSPhotoPickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        a = UIView(frame: CGRect(x: 0, y: 400, width: 100, height: 100))
        a.backgroundColor = UIColor.green
        view.addSubview(a)
    }

    @IBAction func click(_ sender: Any) {
        
        let _ = JSPhotoPickerController(complete: {
            $0.0.dismiss(animated: true, completion: nil)
        }, cancel: {
            $0.dismiss(animated: true, completion: nil)
        }).display()
    }


}
