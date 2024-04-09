//
//  kConstants.swift
//  MusicPlayer
//
//  Created by Suvendu Kumar on 07/04/24.
//

import Foundation


struct NOTIFCATION_NAME {
    static let SONG_STARTED_PLAYING = "SONG_STARTED_PLAYING" // Check for current song started Playing
    static let PLAYBACK_ERROR = "PLAYBACK_ERROR" // If there is error in playing a song
    static let SONG_FINISHED_PLAYING = "SONG_FINISHED_PLAYING" // If current song Finished playing
    static let UPDATE_INITIAL_SONG_IN_GLOBAL_PLAYER = "UPDATE_INITIAL_SONG_IN_GLOBAL_PLAYER" // Update current song data in global play bar view
    static let SONG_PAUSED = "SONG_PAUSED"
    static let NAVIGATE_TAB  = "NAVIGATE_TAB"
}
