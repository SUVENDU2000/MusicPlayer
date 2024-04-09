//
//  MusicTVC.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 08/04/24.
//

import UIKit

class MusicTVC: UITableViewCell {
    
    
    @IBOutlet weak var musicCoverImage: ImageLoadView!
    @IBOutlet weak var musicNameLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.musicCoverImage.layer.cornerRadius = musicCoverImage.frame.height / 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
