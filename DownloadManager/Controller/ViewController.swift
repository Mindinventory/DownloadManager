//
//  ViewController.swift
//  SampleDownloadManager
//
//  Created by mac-00017 on 14/06/21.
//

import UIKit
import AVKit





class ViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!

    //MARK: - Constants
    let downloadService = DownaloadServices.shared
    let audioManager = AudioManager.shared

    //MARK: - Private Properties
    private var player: AVAudioPlayer? = nil
    private var audioStateManager: [IndexPath: PlayerAudioState] = [:]
    private var downloadManager: [IndexPath: DownloadState] = [:]
    private var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var tracks: [Track] = [Track]() {
        didSet {
            self.tableView.reloadData()
        }
    }



    //MARK: - Lazy Stored Properties
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "com.raywenderlich.HalfTunes.bgSession")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()


    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tracks"
        self.initalSetup()
    }



    private func initalSetup() {
        self.tableView.register(TrackCell.self, forNib: true)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        self.downloadService.urlSession = self.downloadsSession
        self.setupDataSource()
    }

    private func setupDataSource() {
        guard let response = JSONHelper.readJSON() else { return }
        self.tracks = response
    }

    func reload(at indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func play(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        let condition = self.indexPath.row == indexPath.row && self.indexPath.section == indexPath.section
        if condition {
            self.audioStateManager[indexPath] = .start
        } else {
            self.audioStateManager[self.indexPath] = .initial
            self.audioStateManager[indexPath] = .start
            self.reload(at: self.indexPath)
            self.indexPath = indexPath
        }

        let track = self.tracks[indexPath.row]
        self.audioManager.playAudio(with: track, atIndex: indexPath, changeIndex: !condition, and: self.audioStateManager, downloadService: self.downloadService) { [weak self] (isPlayed) in
            guard let strongSelf = self else { return }
            if isPlayed {
                strongSelf.reload(at: indexPath)
            }
        }
    }

    func pauseAudio(atIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.audioManager.pauseAudio { [weak self] (isPaused) in
            guard let strongSelf = self else { return }
            if isPaused {
                strongSelf.audioStateManager[indexPath] = .pause
                strongSelf.reload(at: indexPath)
            }
        }

    }



    func stopAudio(atIndex index: Int)  {
        let indexPath = IndexPath(row: index, section: 0)

        self.audioManager.stopAudio { [weak self] (isStopped) in
            guard let strongSelf = self else { return }
            strongSelf.audioStateManager[indexPath] = .initial
            strongSelf.reload(at: indexPath)
        }

    }




}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = self.tracks[indexPath.row]
        if let url = URL(string: track.previewURL), let destinationURL = downloadService.localFilePath(for: url) {

            print(destinationURL.path)
            if downloadService.isFileExist(destinationPath: destinationURL.path) {
                print("this song can play")
            } else {
                print("this song is not in your local directory. need to download")
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReuseableCell(TrackCell.self, at: indexPath) {

            cell.onTapped = { [weak self] (state, indexPath) in
                guard let stongSelf = self, let ip = indexPath else { return }
                stongSelf.audioStateManager[ip] = state
                switch state {
                case .start:
                    stongSelf.pauseAudio(atIndex: ip.row)
                case .pause:
                    stongSelf.play(atIndex: ip.row)
                case .stop:
                    stongSelf.stopAudio(atIndex: ip.row)
                case .initial:
                    stongSelf.player = nil
                    stongSelf.play(atIndex: ip.row)
                }
            }
            cell.onDownload = { [weak self] (state, indexPath) in
                guard let strongSelf = self, let selectedIndexPath = indexPath else { return }
                strongSelf.downloadManager[selectedIndexPath] = state
                switch state {
                case .start:
                    strongSelf.downloadService.start(with: strongSelf.tracks[selectedIndexPath.row], downloadState: state)
                case .pause:
                    strongSelf.downloadService.pauseTask(with: strongSelf.tracks[selectedIndexPath.row], downloadState: state)
                case .resume:
                    strongSelf.downloadService.resumeTask(with: strongSelf.tracks[selectedIndexPath.row], downloadState: state)
                case .cancel:
                    strongSelf.downloadService.cancelTask(with: strongSelf.tracks[selectedIndexPath.row], downloadState: state)
                case .alreadyDownloaded, .none:
                    break

                }
            }
            let audioState = self.audioStateManager[indexPath]
            let downloadState = self.downloadManager[indexPath]
            let track = self.tracks[indexPath.row]
            cell.configure(with: track, isDownloaded: track.isDownloaded, and: downloadService.activeDownloads[URL(string: track.previewURL)!], state: audioState, downloadState: downloadState, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()


    }
}

extension ViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Task has been resumed")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {



        guard let sourceUrl = downloadTask.originalRequest?.url else {
            return
        }

        let download = downloadService.activeDownloads[sourceUrl]
        downloadService.activeDownloads[sourceUrl] = nil

        guard let destinationURL = downloadService.localFilePath(for: sourceUrl) else { return }
        print(destinationURL)

        guard let index = self.tracks.firstIndex(where: {$0.previewURL == sourceUrl.absoluteString}) else { return }

        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            download?.isDownloading = false
            download?.track.isDownloaded = true
            let indexPath = IndexPath(row: index, section: 0)
            self.downloadManager[indexPath] = .alreadyDownloaded

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        debugPrint("ByteWritten: \(bytesWritten)")
        debugPrint("TotalbyteWritten:\(totalBytesWritten)")
        debugPrint("TotalExpectedBytes:\(totalBytesExpectedToWrite)")
        print(downloadTask.originalRequest?.url)
      // 1
      guard
        let url = downloadTask.originalRequest?.url,
        let download = downloadService.activeDownloads[url]  else {
          return
      }

        guard let index = self.tracks.firstIndex(where: {$0.previewURL == url.absoluteString}) else { return }

      // 2
        download.progress = Double(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
      // 3
      let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)

      // 4
      DispatchQueue.main.async {
        if let trackCell = self.tableView.cellForRow(at: IndexPath(row: index,
                                                                   section: 0)) as? TrackCell {
            trackCell.updateDisplay(progress: download.progress, totalSize: totalSize)
        }
      }
    }
}




