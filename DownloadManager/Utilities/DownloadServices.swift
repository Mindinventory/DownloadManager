//
//  DownloadServices.swift
//  SampleDownloadManager
//
//  Created by mac-00017 on 14/06/21.
//

import Foundation

enum ButtonTitle {
    static let download = "Download"
    static let pause = "Pause"
    static let resume = "Resume"
}

enum DownloadState: Int, CustomStringConvertible {
    case none = 0
    case start
    case pause
    case resume
    case cancel
    case alreadyDownloaded

    var isOngoing: Bool {
        return self == .start || self == .resume
    }

    var buttonTitle: String {
        switch self {
        case .none:
            return ButtonTitle.download
        case .start, .resume:
            return ButtonTitle.pause
        case .alreadyDownloaded, .cancel:
            return ""
        case .pause:
            return ButtonTitle.resume
        }
    }

    var isButtonHide: Bool {
        switch self {
        case .alreadyDownloaded, .cancel:
            return true
        default:
            return false

        }
    }

    var isHideCancelButton: Bool {
        switch self {
        case .start, .pause, .resume:
            return false
        case .alreadyDownloaded:
            return true
        default:
            return true
        }
    }

    var description: String {
        switch self {
        case .start:
            return "Download about start"
        case .resume:
            return "Download will resume"
        case .pause:
            return "Download is paused"

        default:
            return ""
        }
    }

}

class DownaloadServices {

    static let shared = DownaloadServices()

    var urlSession: URLSession = URLSession(configuration: .default)
    var activeDownloads: [URL: Download] = [:]


    func localFilePath(for url: URL) -> URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }

    func isFileExist(destinationPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: destinationPath)
    }

    func cancelTask(with track: Track, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: track.previewURL)!] else { return }

        download.sessionTask?.cancel()
        download.isDownloading = false
        activeDownloads[URL(string: track.previewURL)!] = nil
        download.dowloadState = downloadState
    }

    func pauseTask(with track: Track, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: track.previewURL)!], download.isDownloading else { return }
        download.sessionTask?.cancel(byProducingResumeData: { (data) in
            download.resumeData = data
        })
        download.dowloadState = downloadState
        download.isDownloading = false
    }

    func resumeTask(with track: Track, downloadState: DownloadState) {
        guard let download = self.activeDownloads[URL(string: track.previewURL)!] else { return }


        if let resumeData = download.resumeData {
            download.sessionTask = urlSession.downloadTask(withResumeData: resumeData)
        } else {
            download.sessionTask = urlSession.downloadTask(with: URL(string: track.previewURL)!)
        }

        download.dowloadState = downloadState
        download.sessionTask?.resume()
        download.isDownloading = true


    }


    func start(with track: Track, downloadState: DownloadState) {
        let download = Download(track: track)
        download.sessionTask = urlSession.downloadTask(with: URL(string: track.previewURL)!)
        download.sessionTask?.resume()
        download.dowloadState = downloadState
        download.isDownloading = true
        if let url = URL(string: track.previewURL)  {
            activeDownloads[url] = download
        }
    }

}
