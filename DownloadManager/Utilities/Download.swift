//
//  Download.swift
//  SampleDownloadManager
//
//  Created by mac-00017 on 14/06/21.
//

import Foundation


class Download {
    var track: Track
    var dowloadState: DownloadState = .none
    var isDownloading: Bool = false
    var progress: Double = 0.0
    var resumeData: Data?
    var sessionTask: URLSessionDownloadTask?


    init(track: Track) {
        self.track = track
    }
}
