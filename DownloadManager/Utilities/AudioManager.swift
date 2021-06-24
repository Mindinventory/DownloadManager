//
//  AudioManager.swift
//  DownloadManager
//
//  Created by mac-00017 on 23/06/21.
//

import Foundation
import UIKit
import AVKit

enum PlayerAudioState {
    case initial
    case start
    case pause
    case stop

    var image: UIImage {
        switch self {
        case .initial, .pause, .stop:
            return #imageLiteral(resourceName: "Play")
        case .start:
            return #imageLiteral(resourceName: "Pause")
        }

    }

    private var isPlaying: Bool {
        switch self {
        case .start:
            return true
        default:
            return false
        }
    }

    var isShowStopButton: Bool {
        return self.isPlaying
    }
}

class AudioManager {

    private var player: AVAudioPlayer? = nil

    static let shared = AudioManager()


    func playAudio(with track: Track, atIndex indexPath: IndexPath, changeIndex: Bool, and audioManager: [IndexPath: PlayerAudioState], downloadService: DownaloadServices, completion: @escaping ConfirmationHandler) {

        if let url = URL(string: track.previewURL), let destinationURL = downloadService.localFilePath(for: url) {
            guard let state = audioManager[indexPath] else { return }
            if changeIndex {
                self.player = nil
            }
            switch state {
            case .start, .initial:
                if player == nil {
                    player = try? AVAudioPlayer(contentsOf: destinationURL)
                    player?.play()
                } else {
                    if let player = player, !player.isPlaying  {
                        player.play()
                    }
                }
                completion(true)
                break
            default:
                completion(false)
                break
            }

        } else {
            completion(false)
        }


    }

    func pauseAudio(with completion: @escaping ConfirmationHandler) {
        if let player = self.player, player.isPlaying {
            player.pause()
            completion(true)
        }
        completion(false)
    }

    func stopAudio(with completion: @escaping ConfirmationHandler) {
        if let player = self.player, player.isPlaying {
            player.stop()
            self.player = nil
            completion(true)

        }
        completion(false)
    }

    


}
