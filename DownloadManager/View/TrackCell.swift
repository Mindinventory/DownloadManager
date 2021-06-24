//
//  TrackCell.swift
//  SampleDownloadManager
//
//  Created by mac-00017 on 14/06/21.
//

import UIKit
import AHDownloadButton







class TrackCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var lbltrack: UILabel!
    @IBOutlet weak var lblArtist: UILabel!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var downloadButton: AHDownloadButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnStop: UIButton!

    //MARK: - Callbacks Properties
    var onTapped: ((PlayerAudioState, IndexPath?) -> Void)?
    var onDownload: ((DownloadState, IndexPath?) -> Void)?

    //MARK: - Private Properties
    private var indexPath: IndexPath?
    private var track: Track? = nil
    private var ongoignProgress: Double = 0.0
    private var downloadState: DownloadState = .none {
        didSet {
            self.onDownload?(self.downloadState, self.indexPath)
        }
    }

    //MARK: - Stored Properties
    var audioState: PlayerAudioState = .initial {
        didSet {
            self.btnPlayPause.setImage(audioState.image, for: .normal)
        }
    }

    //MARK: - Life Cycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        print(#function, "Called")
        self.initialSetup()
    }

    //MARK: - Initialize Method
    private func initialSetup() {
        self.selectionStyle = .none
        self.btnStop.isHidden = true
        self.downloadButton.startDownloadButtonTitle = "Download"
        self.downloadButton.startDownloadButtonTitleFont = UIFont.systemFont(ofSize: 12.0)
        self.downloadButton.downloadingButtonCircleLineWidth = 2.0
        self.downloadButton.pendingCircleLineWidth = 2.0
        self.downloadButton.delegate = self
        self.lblProgress.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.downloadButton.state = .startDownload
        self.downloadButton.progress = 0.0

    }




    //MARK: - Instance Methods
    func configure(with track: Track, isDownloaded: Bool, and download: Download?, state: PlayerAudioState?, downloadState: DownloadState?, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.downloadState = downloadState ?? .none
        self.audioState = state ?? .initial
        self.lbltrack.text = track.trackName
        self.lblArtist.text = track.artistName.rawValue
        self.lblProgress.isHidden = true

        if let url = URL(string: track.previewURL), let destinationURL = DownaloadServices.shared.localFilePath(for: url) {
            self.btnPlayPause.isHidden = !DownaloadServices.shared.isFileExist(destinationPath: destinationURL.path)
            self.btnStop.isHidden = !self.audioState.isShowStopButton
            self.downloadButton.isHidden = DownaloadServices.shared.isFileExist(destinationPath: destinationURL.path)
        }
    }

    func updateDisplay(progress: Double, totalSize : String) {
        self.lblProgress.isHidden = false
        self.ongoignProgress = progress
        self.downloadButton.progress = CGFloat(progress)
        let percentage = Int(progress * 100)
        self.lblProgress.text = "\(percentage)%"
    }

    //MARK: - IBActions
    @IBAction func playPasueAction(_ sender: UIButton) {
        guard let ip = self.indexPath else { return }
        self.onTapped?(self.audioState, ip)
    }

    @IBAction func stopAction(_ sender: UIButton) {
        guard let ip = self.indexPath else { return }
        self.audioState = .stop
        self.onTapped?(self.audioState, ip)
    }
}

//MARK: - AHDownloadButtonDelegate
extension TrackCell: AHDownloadButtonDelegate {
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        self.lblProgress.isHidden = !self.downloadState.isOngoing
        print(self.downloadState.description)
        switch state {
        case .startDownload:
            self.downloadButton.state = .pending
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.downloadButton.state = .downloading
                self.downloadState = .start
            }
            break

        case .downloading:
            downloadButton.progress = CGFloat(self.ongoignProgress)
            downloadButton.state = .downloading
            self.downloadState = self.downloadState.isOngoing ? .pause : .resume
            break
        case .downloaded:
            self.lblProgress.isHidden = true
            self.downloadButton.isHidden = true
        default:
            break
        }
    }


}


