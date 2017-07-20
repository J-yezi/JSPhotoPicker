//
//  JSAlbumModel.swift
//  JSPhotoPicker
//
//  Created by jesse on 1/24/17.
//  Copyright © 2017 jesse. All rights reserved.
//

import Foundation
import Photos

struct JSAlbumModel {
    
    let album: PHAssetCollection
    let title: String?
    let count: Int
    var photos: PHFetchResult<PHAsset>

    init(album: PHAssetCollection) {
        self.album = album
        title = album.localizedTitle
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        photos = PHAsset.fetchAssets(in: album, options: options)
        count = photos.count
    }
    
}
