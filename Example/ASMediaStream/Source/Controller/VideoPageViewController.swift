//
//  VideoPageViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 07.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import UIKit
import WebRTC
import SnapKit

class VideoPageViewController: UIViewController {

    // MARK: - Views
    
    @IBOutlet weak var videoWrapperView: UIView!
    
    // MARK: - Public properties

    var videoTrack: RTCVideoTrack?
    var clientId: String?
    
    // MARK: - Private properties
    
    private var videoRenderer: RTCVideoRenderer!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupVideoView()
        self.videoTrack?.add(self.videoRenderer)
    }
}

// MARK: - Setup

extension VideoPageViewController {
    private func setupVideoView() {
        let currentVideoView: UIView
        
        #if RTC_SUPPORTS_METAL
            let videoView = RTCMTLVideoView(frame: .zero)
            videoView.videoContentMode = .scaleAspectFill
            videoView.delegate = self
            self.videoRenderer = videoView
            currentVideoView = videoView
        #else
            let videoView = RTCEAGLVideoView(frame: .zero)
            videoView.delegate = self
        
            self.videoRenderer = videoView
            currentVideoView = videoView
        #endif
        
        currentVideoView.translatesAutoresizingMaskIntoConstraints = false
        self.videoWrapperView.addSubview(currentVideoView)
        
        currentVideoView.snp.makeConstraints { maker in
            maker.top.equalTo(self.videoWrapperView.snp.top)
            maker.bottom.equalTo(self.videoWrapperView.snp.bottom)
            maker.centerX.equalTo(self.videoWrapperView.snp.centerX)
            maker.height.equalTo(currentVideoView.snp.width).multipliedBy(640.0 / 480.0)
        }
    }
}

// MARK: - RTCVideoViewDelegate

extension VideoPageViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}
