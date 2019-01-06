//
//  VideoViewController.swift
//  WebRTCExample
//
//  Created by Robert Mietelski on 12.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import UIKit
import ASMediaStream
import WebRTC
import PromiseKit

class VideoViewController: UIViewController {

    // MARK: - Views
    
    @IBOutlet weak var localVideoView: RTCEAGLVideoView!
    @IBOutlet weak var remoteVideoStackView: UIStackView!
    
    // MARK: - Public properties
    
    var roomName: String = ""
    
    // MARK: - Private properties

    private lazy var turnServer: RTCIceServer = {
        return RTCIceServer(urlStrings: ["https://appr.tc"])
    }()
    
    private lazy var stunServer: RTCIceServer = {
        let urlStrings = ["stun:stun.sipgate.net:3478",
                          "stun:stun2.l.google.com:19302",
                          "stun:stun3.l.google.com:19302",
                          "stun:stun4.l.google.com:19302"]
        return RTCIceServer(urlStrings: urlStrings)
    }()
    
    private lazy var client: ASMediaStreamClient = {
        let client = ASMediaStreamClient(iceServers: [self.stunServer], sessionFactory: WebSocketSessionFactory())
        client.delegate = self
        
        return client
    }()
    
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoDictionary: [RTCVideoTrack: RTCEAGLVideoView] = [:]
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLocalVideoView()
        
        firstly {
            self.videoAuthorizationRequest()
        } .then { _ in
            self.audioAuthorizationRequest()
        } .done { _ in
            self.client.connectToRoom(name: self.roomName)
        } .catch { error in
            self.showDialog(title: "Wystąpił błąd", message: error.localizedDescription, cancelButtonTitle: "Ok")
        }
    }
}

// MARK: - Setup

extension VideoViewController {
    private func setupLocalVideoView() {
        self.localVideoView.delegate = self
    }
}

extension VideoViewController {
    private func videoAuthorizationRequest() -> Promise<Void> {
        if ASMediaStreamClient.AuthorizationState.isVideoEnabled {
            return Promise()
        }
        return Promise { promise in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    promise.fulfill(())
                } else {
                    let error = NSError(domain: "PermissionDomain",
                                        code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "Nie masz uprawnień do aparatu."])
                    promise.reject(error)
                }
            }
        }
    }
    
    private func audioAuthorizationRequest() -> Promise<Void> {
        if ASMediaStreamClient.AuthorizationState.isAudioEnabled {
            return Promise()
        }
        return Promise { promise in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    promise.fulfill(())
                } else {
                    let error = NSError(domain: "PermissionDomain",
                                        code: 2,
                                        userInfo: [NSLocalizedDescriptionKey: "Nie masz uprawnień do mikrofonu."])
                    promise.reject(error)
                }
            }
        }
    }
}

// MARK: - Setup

extension VideoViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}

extension VideoViewController: ASMediaStreamClientDelegate {
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalVideoTrack videoTrack: RTCVideoTrack) {
        if let videoTrack = self.localVideoTrack {
            videoTrack.remove(self.localVideoView)
        }
        videoTrack.add(self.localVideoView)
        client.videoCapturer?.startCapture()
        self.localVideoTrack = videoTrack
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalVideoTrack videoTrack: RTCVideoTrack) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalAudioTrack audioTrack: RTCAudioTrack) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalAudioTrack audioTrack: RTCAudioTrack) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteVideoTracks videoTracks: [RTCVideoTrack]) {
        for videoTrack in videoTracks {
            let videoView = RTCEAGLVideoView(frame: .zero)
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.delegate = self
            videoTrack.add(videoView)
            self.remoteVideoStackView.addArrangedSubview(videoView)
            
            self.remoteVideoDictionary[videoTrack] = videoView
            self.view.setupConstraint(item: videoView, attribute: .height, toItem: self.view, attribute: .height, multiplier: 0.5)
        }
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteVideoTracks videoTracks: [RTCVideoTrack]) {
        for videoTrack in videoTracks {
            if let videoView = self.remoteVideoDictionary[videoTrack] {
                videoTrack.remove(videoView)
                
                self.remoteVideoDictionary[videoTrack] = nil
                self.remoteVideoStackView.removeArrangedSubview(videoView)
            }
        }
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error) {
        self.showDialog(title: "Wystąpił błąd", message: error.localizedDescription, cancelButtonTitle: "Ok")
    }
}
