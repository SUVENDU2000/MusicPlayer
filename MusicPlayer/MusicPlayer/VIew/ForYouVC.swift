//
//  ForYouVC.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit
import AVFoundation


class ForYouVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    private var musicList : [Musics] = []
    let activityIndicatoryView  = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSongStatusUI), name: Notification.Name.init(NOTIFCATION_NAME.SONG_STARTED_PLAYING), object: nil)
        
        setupIndicatorView()
        configUI()
    }
    
    // Setup indicator view
    func setupIndicatorView() {
        view.addSubview(activityIndicatoryView)
        activityIndicatoryView.startAnimating()
        
        activityIndicatoryView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatoryView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicatoryView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    // Setup UI
    func configUI() {
        tblView.register(UINib(nibName: "MusicTVC", bundle: nil), forCellReuseIdentifier: "MusicTVC")
        APIManager.shared.fetchMusics { data in
            if !data.data.isEmpty {
                self.musicList = data.data
                DispatchQueue.main.async {
                    
                    // After fetching all music list, assign first song to global player view. This will not be feasible in case of larger amount of data. Instead use storage managerment to store last played song
                    PlayerManager.shared.currentTrack = self.musicList[0]
                    PlayerManager.shared.musicList = self.musicList
                    PlayerManager.shared.currentTrackIndex = 0
                    NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.UPDATE_INITIAL_SONG_IN_GLOBAL_PLAYER), object: nil)
                    
                    // remove activity indicator when data fetched
                    self.activityIndicatoryView.stopAnimating()
                    self.activityIndicatoryView.removeFromSuperview()
                    self.tblView.reloadData()
                }
            }
        }
    }

    
    // Update Global Player View data
    @objc func updateSongStatusUI() {
        DispatchQueue.main.async {
            AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "MusicTVC", for: indexPath) as! MusicTVC
        let listInfo = musicList[indexPath.row]
        let imageUrl = URL(string: "\(APIManager.shared.IMAGE_URL)\(listInfo.cover)")!
        cell.musicCoverImage.getImage(imageURL: imageUrl)
        cell.musicNameLbl.text = listInfo.name
        cell.artistNameLbl.text = listInfo.artist
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Generate feedback when song tapped
        hepticFeedBackGenerator()
        PlayerManager.shared.player?.stop()
        PlayerManager.shared.currentTrackIndex = indexPath.row
        PlayerManager.shared.currentTrack = musicList[indexPath.row]
        PlayerManager.shared.musicList = musicList
        PlayerManager.shared.prepareToPlayTrack(musicList[indexPath.row].url)
        AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
    }
}
