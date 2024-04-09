//
//  SongsCoverImageCVC.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 08/04/24.
//

import UIKit

class SongsCoverImageCVC: UICollectionViewCell {
    
    @IBOutlet weak var songsCoverImage: ImageLoadView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.songsCoverImage.layer.cornerRadius = 5
        // Initialization code
    }

}
