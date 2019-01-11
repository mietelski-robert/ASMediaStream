//
//  VideoPageViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 07.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import WebRTC

protocol VideoPageViewControllerDelegate: class {
    func videoPageViewControllerSwitchCamera(in viewController: VideoPageViewController)
    
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeVideoEnabled isEnabled: Bool)
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeAudioEnabled isEnabled: Bool)
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeFlashlightState isOn: Bool)
}

class VideoPageViewController: UIViewController {

    // MARK: - Views
    
    @IBOutlet weak var videoWrapperView: UIView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    
    // MARK: - Public properties

    var videoTrack: RTCVideoTrack?
    var clientId: String?
    
    weak var delegate: VideoPageViewControllerDelegate?
    var position: AVCaptureDevice.Position = .front
    
    // MARK: - Private properties
    
    private var videoRenderer: RTCVideoRenderer!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupVideoView()
        self.setupButtons()
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
        
        self.view.setupConstraint(item: currentVideoView, attribute: .top, toItem: self.videoWrapperView, attribute: .top)
        self.view.setupConstraint(item: self.videoWrapperView, attribute: .bottom, toItem: currentVideoView, attribute: .bottom)
        self.view.setupConstraint(item: currentVideoView, attribute: .leading, toItem: self.videoWrapperView, attribute: .leading)
        self.view.setupConstraint(item: self.videoWrapperView, attribute: .trailing, toItem: currentVideoView, attribute: .trailing)
    }
    
    private func setupButtons() {
        let imageEdgeInsets = UIEdgeInsets(top: 12.5, left: 12.5, bottom: 12.5, right: 12.5)
        let image = UIColor.white.image(size: CGSize(width: 60.0, height: 60.0), radius: 30.0)

        self.videoButton.setBackgroundImage(image, for: UIControlState.normal)
        self.audioButton.setBackgroundImage(image, for: UIControlState.normal)
        self.switchCameraButton.setBackgroundImage(image, for: UIControlState.normal)
        self.cameraFlashButton.setBackgroundImage(image, for: UIControlState.normal)
        
        self.videoButton.imageEdgeInsets = imageEdgeInsets
        self.audioButton.imageEdgeInsets = imageEdgeInsets
        self.switchCameraButton.imageEdgeInsets = imageEdgeInsets
        self.cameraFlashButton.imageEdgeInsets = imageEdgeInsets
        
        self.videoButton.imageView?.contentMode = .scaleAspectFit
        self.audioButton.imageView?.contentMode = .scaleAspectFit
        self.switchCameraButton.imageView?.contentMode = .scaleAspectFit
        self.cameraFlashButton.imageView?.contentMode = .scaleAspectFit
    }
}

// MARK: - Actions

extension VideoPageViewController {
    @IBAction func enableVideoAction(_ sender: UIButton) {
        let isEnabled = !sender.isSelected
        
        sender.isSelected = isEnabled
        self.delegate?.videoPageViewController(self, didChangeVideoEnabled: isEnabled)
    }
    
    @IBAction func enableAudioAction(_ sender: UIButton) {
        let isEnabled = !sender.isSelected
        
        sender.isSelected = isEnabled
        self.delegate?.videoPageViewController(self, didChangeAudioEnabled: isEnabled)
    }
    
    @IBAction func switchCameraAction(_ sender: UIButton) {
        self.delegate?.videoPageViewControllerSwitchCamera(in: self)
    }
    
    @IBAction func turnOnFlashlightAction(_ sender: UIButton) {
        let isOn = !sender.isSelected
        
        sender.isSelected = isOn
        self.delegate?.videoPageViewController(self, didChangeFlashlightState: isOn)
    }
}

// MARK: - Setup

extension VideoPageViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}
