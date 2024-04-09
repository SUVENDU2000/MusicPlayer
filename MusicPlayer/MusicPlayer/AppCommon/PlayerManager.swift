//
//  PlayerManager.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

// Global Player Manager for handling Audiosession
final class PlayerManager : NSObject, AVAudioPlayerDelegate {
    static let shared = PlayerManager()
    
    
    var musicList : [Musics] = [Musics]()
    var currentTrack : Musics = Musics()
    var currentTrackIndex : Int = Int()
    
    var player : AVAudioPlayer?
    
    // Start Audio Session to play song
    func prepareToPlayTrack(_ songUrl : String) {
        DispatchQueue.global().async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
                self.playSong(songUrl)
            } catch {
                print(error)
            }
        }

    }
    
    
    // Prepare song data to be played
    func playSong(_ songUrl : String) {
        DispatchQueue.global().async {
            do {
                if let url = URL(string: songUrl) {
                    let soundData = try Data(contentsOf: url)
                    self.player = try AVAudioPlayer(data: soundData)
                    self.player?.prepareToPlay()
                    self.player?.delegate = self
                    self.player?.play()
                    NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_STARTED_PLAYING), object: nil)
                    MPMediaPlayerManager.shared.updateNowPlayingInfo()
                }
            } catch {
                NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.PLAYBACK_ERROR), object: nil)
                print(error)
            }
        }
        
        
    }
    
    
    // Play song at slider value
    @objc func playSongWithSliderValue(value : CGFloat) {
        if let player = PlayerManager.shared.player {
            let newPosition = TimeInterval(value)
            player.currentTime = newPosition
            player.play()
        }
    }


    
    // Check if Current Song finished playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFCATION_NAME.SONG_FINISHED_PLAYING), object: nil)
        
        if let index = musicList.firstIndex(where: { $0.id == currentTrack.id }) {
            if index == musicList.count - 1 {
                return
            } else {
                currentTrackIndex = index + 1
            }
            setupCurrentSong()
            AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
        }
        
    }
    
    func playPauseSong() {
        if let isPlaying = PlayerManager.shared.player?.isPlaying {
            if isPlaying {
                PlayerManager.shared.player?.pause()
            } else {
                PlayerManager.shared.player?.play()
            }
            AppDelegate().sharedDelegate().setupCurrentTrackInGlobalView()
        } else {
            PlayerManager.shared.prepareToPlayTrack(PlayerManager.shared.currentTrack.url)
        }
    }
    
    // for play next song
    func playNextSong() {
        if let index = musicList.firstIndex(where: { $0.id == currentTrack.id }) {
            if index == musicList.count - 1 {
                return
            } else {
                currentTrackIndex = index + 1
            }
            setupCurrentSong()
        }
    }
    
    // for previous song play
    func playPreviousSong() {
        
        if let index = musicList.firstIndex(where: { $0.id == currentTrack.id }) {
            if index == 0 {
                return
            } else {
                currentTrackIndex = index - 1
            }
            setupCurrentSong()
        }
    }
    
    
    
    // This function use for setup current song id and song detail
    // Ansd start playing
    func setupCurrentSong() {
        currentTrack = musicList[currentTrackIndex]
        prepareToPlayTrack(currentTrack.url)
    }

    
}
