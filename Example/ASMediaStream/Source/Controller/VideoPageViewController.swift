//
//  VideoPageViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 07.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import WebRTC

class VideoPageViewController: UIViewController {

    // MARK: - Views
    
    @IBOutlet weak var videoView: RTCMTLVideoView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    
    // MARK: - Public properties
    
    var videoTrack: RTCVideoTrack?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupVideoView()
        self.setupButtons()
    }
}

// MARK: - Setup

extension VideoPageViewController {
    private func setupVideoView() {
        self.videoTrack?.add(self.videoView)
        self.videoView.videoContentMode = .scaleAspectFit
        self.videoView.delegate = self
    }
    
    private func setupButtons() {
        self.videoButton.setTitle("Turn on/off video", for: UIControlState.normal)
        self.audioButton.setTitle("Turn on/off audio", for: UIControlState.normal)
        self.switchCameraButton.setTitle("Switch camera", for: UIControlState.normal)
        self.cameraFlashButton.setTitle("Turn on/off flash", for: UIControlState.normal)
        
        self.videoButton.titleLabel?.numberOfLines = 0
        self.audioButton.titleLabel?.numberOfLines = 0
        self.switchCameraButton.titleLabel?.numberOfLines = 0
        self.cameraFlashButton.titleLabel?.numberOfLines = 0
    }
}

// MARK: - Setup

extension VideoPageViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}
