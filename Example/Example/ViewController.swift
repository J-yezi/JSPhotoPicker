//
//  ViewController.swift
//  Example
//
//  Created by jesse on 2017/7/20.
//  Copyright © 2017年 jesse. All rights reserved.
//

import UIKit
import JSPhotoPicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func click(_ sender: Any) {
        presentImagePickerController(picker: JSPhotoPickerController())
    }


}

