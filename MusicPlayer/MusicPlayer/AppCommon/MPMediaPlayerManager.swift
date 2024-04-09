//
//  MediaPlayerManager.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import UIKit
import MediaPlayer

class MPMediaPlayerManager: UIViewController {
    
    static let shared = MPMediaPlayerManager()
    var nowPlayingInfo = [String : Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()

        // Set metadata for the currently playing song
        nowPlayingInfo[MPMediaItemPropertyTitle] = PlayerManager.shared.currentTrack.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = PlayerManager.shared.currentTrack.artist

        if let imageUrl = URL(string: "\(APIManager.shared.IMAGE_URL)\(PlayerManager.shared.currentTrack.cover)") {
            if let imageData = try? Data(contentsOf: imageUrl) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 1024, height: 1024)) { _ in
                    return UIImage(data: imageData) ?? UIImage()
                }
            }
        }
        
        // Set the elapsed playback time and total duration
        if let player = PlayerManager.shared.player {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            // Handle play action
            NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_PAUSED), object: nil)
            PlayerManager.shared.playPauseSong()
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            // Handle pause action
            NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_PAUSED), object: nil)
            PlayerManager.shared.playPauseSong()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { _ in
            // Handle next track action
            PlayerManager.shared.playNextSong()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            // Handle previous track action
            PlayerManager.shared.playPreviousSong()
            return .success
        }
        
        commandCenter.seekForwardCommand.addTarget { event in
            print("Seek Forward")
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { _ in
            print("Seek Backward")
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }

            let positionTime = positionEvent.positionTime
            PlayerManager.shared.playSongWithSliderValue(value: positionTime)
            
            return .success
        }
    }

    func startUpdatingNowPlayingInfo() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackStateChanged), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        // Add other notifications for playback state changes as needed
    }

    @objc func handlePlaybackStateChanged() {
        updateNowPlayingInfo()
    }

    func requestRemoteCommandHandling() {
        try? AVAudioSession.sharedInstance().setActive(true)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    

}
