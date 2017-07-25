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
        
    }

    @IBAction func click(_ sender: Any) {
        
        let _ = JSPhotoPickerController(complete: {
            $0.0.dismiss(animated: true, completion: nil)
        }, cancel: {
            $0.dismiss(animated: true, completion: nil)
        }).display()
    }


}
