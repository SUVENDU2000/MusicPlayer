//
//  TabBarView.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit

protocol TabBarViewDelegate
{
    func tabSelectedAtIndex(index:Int)
}

class TabBarView: UIView {
    
    @IBOutlet weak var forYouLbl: UILabel!
    @IBOutlet weak var forYouSelectedView: UIView!
    @IBOutlet weak var topTracksSelectedView: UIView!
    @IBOutlet weak var topTracksLbl: UILabel!
    @IBOutlet weak var globalPlayerView: UIView!
    @IBOutlet weak var songConverImage: ImageLoadView!
    @IBOutlet weak var songNameLbl: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var forYouTabBtn: UIButton!
    @IBOutlet weak var topTracksTabBtn: UIButton!
    
    var delegate:TabBarViewDelegate?
    
    var lastIndex : NSInteger!
    let loaderView = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        forYouSelectedView.layer.cornerRadius = 5
        topTracksSelectedView.layer.cornerRadius = 5
        topTracksLbl.alpha = 0.6
        topTracksSelectedView.isHidden = true
        
        songConverImage.layer.cornerRadius = songConverImage.frame.height / 2
        playPauseBtn.addTarget(self, action: #selector(playPauseSong), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(changeSong), for: .touchUpInside)
        
        globalPlayerView.addTapGesture {
            let vc = SongPlayerVC()
            vc.selectedMusic = PlayerManager.shared.currentTrack
            vc.musicList = PlayerManager.shared.musicList
            vc.position = PlayerManager.shared.currentTrackIndex
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalPresentationCapturesStatusBarAppearance = true
            AppDelegate().sharedDelegate().tabBarController.present(vc, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupCurrentTrackData), name: NSNotification.Name.init(NOTIFCATION_NAME.UPDATE_INITIAL_SONG_IN_GLOBAL_PLAYER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSongStatusUI), name: Notification.Name.init(NOTIFCATION_NAME.SONG_STARTED_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(songFinishedPlaying), name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_FINISHED_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(songPausedUI), name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_PAUSED), object: nil)
        
        setUpLoaderView()
        initialize()
    }
    
    func setUpLoaderView() {
        playPauseBtn.addSubview(loaderView)
        
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: self.playPauseBtn.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: self.playPauseBtn.centerYAnchor).isActive = true
        loaderView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
    }
    
    // Setup Current Track in Global Play Bar View
    @objc func setupCurrentTrackData() {
        DispatchQueue.main.async {
            self.loaderView.color = colorFromHex(hex: PlayerManager.shared.currentTrack.accent)
            self.songConverImage.getImage(imageURL: URL(string: "\(APIManager.shared.IMAGE_URL)\(PlayerManager.shared.currentTrack.cover)")!)
            self.songNameLbl.text = PlayerManager.shared.currentTrack.name
            self.globalPlayerView.backgroundColor = colorFromHex(hex: PlayerManager.shared.currentTrack.accent)
            if let player = PlayerManager.shared.player {
                let isPlaying = player.isPlaying
                self.playPauseBtn.isSelected = isPlaying
            }
            if PlayerManager.shared.currentTrackIndex == PlayerManager.shared.musicList.count - 1 {
                self.nextBtn.isEnabled = false
            } else {
                self.nextBtn.isEnabled = true
            }
        }
        

    }
    
    @objc func songFinishedPlaying() {
        DispatchQueue.main.async {
            self.playPauseBtn.isSelected = false
            self.setupCurrentTrackData()
        }
    }
    
    @objc func songPausedUI() {
        DispatchQueue.main.async {
            self.playPauseBtn.isSelected = !self.playPauseBtn.isSelected
        }
    }
    
    @objc func updateSongStatusUI() {
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.playPauseBtn.isSelected = true
        }
        
    }
    
    @objc func playPauseSong() {
        hepticFeedBackGenerator()
        if let player = PlayerManager.shared.player {
            let isPlaying = player.isPlaying
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            playPauseBtn.isSelected = !playPauseBtn.isSelected
        } else {
            loaderView.startAnimating()
            PlayerManager.shared.prepareToPlayTrack(PlayerManager.shared.currentTrack.url)
        }
    }

    @objc func changeSong() {
        hepticFeedBackGenerator()
        PlayerManager.shared.player?.stop()
        playPauseBtn.isSelected = false
        PlayerManager.shared.playNextSong()
        setupCurrentTrackData()
        loaderView.startAnimating()
    }
    
    func initialize()
    {
        lastIndex = 0
    }
    
    @IBAction func tabBtnClicked(_ sender: UIButton)
    {
        let tabBtn: UIButton = sender
        lastIndex = tabBtn.tag - 1
        
        resetAllButton()
        selectTabButton()
    }
    
    func resetAllButton()
    {
        forYouLbl.alpha = 0.6
        topTracksLbl.alpha = 0.6
        forYouSelectedView.isHidden = true
        topTracksSelectedView.isHidden = true
    }
    
    func selectTabButton()
    {
        switch lastIndex {
        case 0:
            forYouLbl.alpha = 1.0
            forYouSelectedView.isHidden = false
            break
        case 1:
            topTracksLbl.alpha = 1.0
            topTracksSelectedView.isHidden = false
            break
        default:
            break
        }
        delegate?.tabSelectedAtIndex(index: lastIndex)
    }
    
    
}
