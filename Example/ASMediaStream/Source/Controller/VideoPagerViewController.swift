//
//  VideoPagerViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 07.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import UIKit
import ASMediaStream
import WebRTC
import PromiseKit

class VideoPagerViewController: ViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    @IBOutlet weak var videoWrapperView: UIView!
    
    // MARK: - Public properties
    
    private(set) var pageViewController: UIPageViewController?
    private(set) var currentPageIndex: Int = 0
    
    var roomName: String = ""
    
    // MARK: - Private properties
    
    private var viewControllers: [UIViewController] = []
    private var videoRenderer: RTCVideoRenderer!
    
    private lazy var turnServer: RTCIceServer = {
        return RTCIceServer(urlStrings: ["turn:numb.viagenie.ca"], username: "nujo@prmail.top", credential: "n6kn4NUPrYUjJjQy")
    }()
    
    private lazy var stunServer: RTCIceServer = {
        return RTCIceServer(urlStrings: ["stun:stun2.l.google.com:19302"])
    }()
    
    private var client: ASMediaStreamClient?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupButtons()
        self.setupVideoView()
        self.setupPageControl()
        
        firstly {
            self.videoAuthorizationRequest()
        } .then { _ in
            self.audioAuthorizationRequest()
        } .done { _ in
            self.client = ASMediaStreamClient(iceServers: [self.stunServer, self.turnServer], sessionFactory: WebSocketSessionFactory())
            self.client?.delegate = self
            self.client?.connectToRoom(name: self.roomName)
        } .catch { error in
            self.showDialog(title: NSLocalizedString("error.title", comment: ""),
                            message: error.localizedDescription,
                            cancelButtonTitle: NSLocalizedString("error.ok", comment: ""))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UIPageViewController {
            self.pageViewController = controller
            self.pageViewController?.delegate = self
            self.pageViewController?.dataSource = self
        }
    }
    
    // MARK: - Actions
    
    @IBAction func enableVideoAction(_ sender: UIButton) {
        let isEnabled = !sender.isSelected
        
        sender.isSelected = isEnabled
        self.client?.isVideoEnabled = isEnabled
    }
    
    @IBAction func enableAudioAction(_ sender: UIButton) {
        let isEnabled = !sender.isSelected
        
        sender.isSelected = isEnabled
        self.client?.isAudioEnabled = isEnabled
    }
    
    @IBAction func switchCameraAction(_ sender: UIButton) {
        self.client?.videoCapturer?.switchCamera()
    }
    
    @IBAction func turnOnFlashlightAction(_ sender: UIButton) {
        let isOn = !sender.isSelected
        
        do {
            if isOn {
                try self.client?.videoCapturer?.turnOnTorch()
            } else {
                try self.client?.videoCapturer?.turnOffTorch()
            }
            self.switchCameraButton.isEnabled = !isOn
            sender.isSelected = isOn
        } catch {
            self.showDialog(title: NSLocalizedString("error.title", comment: ""),
                            message: error.localizedDescription,
                            cancelButtonTitle: NSLocalizedString("error.ok", comment: ""))
        }
    }
    
    @objc func showMore() {
        self.stackView.isHidden = !self.stackView.isHidden
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
}

// MARK: - Setup

extension VideoPagerViewController {
    private func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"),
                                                                style: UIBarButtonItemStyle.plain,
                                                                target: self,
                                                                action: #selector(dismissViewController))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"),
                                                                 style: UIBarButtonItemStyle.plain,
                                                                 target: self,
                                                                 action: #selector(showMore))
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
    
    private func setupPageControl() {
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = .white
    }
}

// MARK: - Page management

extension VideoPagerViewController {
    private func videoPageViewController(peerId: String?, videoTrack: RTCVideoTrack?) -> UIViewController {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "VideoPageViewControllerIdentifier")
        
        if let videoPageViewController = viewController as? VideoPageViewController {
            videoPageViewController.videoTrack = videoTrack
            videoPageViewController.peerId = peerId
        }
        return viewController
    }
    
    private func index(of viewController: UIViewController) -> Int? {
        return self.viewControllers.firstIndex(of: viewController)
    }
    
    private func viewControllerItems(of videoTracks: [RTCVideoTrack]) -> [(offset: Int, element: UIViewController)] {
        return self.viewControllers.enumerated().filter { (offset, element) in
            guard let videoTrack = (element as? VideoPageViewController)?.videoTrack else {
                return false
            }
            return videoTracks.contains(videoTrack)
        }
    }
    
    private func makeViewControllers(peerId: String?, videoTracks: [RTCVideoTrack]) -> [UIViewController] {
        return videoTracks.map { self.videoPageViewController(peerId: peerId, videoTrack: $0) }
    }
}

// MARK: - Permissions management

extension VideoPagerViewController {
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
                                        userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("error.videoPermission", comment: "")])
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
                                        userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("error.audioPermission", comment: "")])
                    promise.reject(error)
                }
            }
        }
    }
}

// MARK: - RTCVideoViewDelegate

extension VideoPagerViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        
    }
}

// MARK: - UIPageViewControllerDataSource

extension VideoPagerViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.currentPageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = self.index(of: viewController), index > 0 else {
            return nil
        }
        self.currentPageIndex = self.viewControllers.index(before: index)
        return self.viewControllers[self.currentPageIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = self.index(of: viewController), index < self.viewControllers.count - 1 else {
            return nil
        }
        self.currentPageIndex = self.viewControllers.index(after: index)
        return self.viewControllers[self.currentPageIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension VideoPagerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        if completed {
            if let viewController = previousViewControllers.last, let index = self.index(of: viewController) {
                self.currentPageIndex = index
            }
        }
    }
}

// MARK: - ASMediaStreamClientDelegate

extension VideoPagerViewController: ASMediaStreamClientDelegate {
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveVideoTrack track: RTCVideoTrack) {
        track.add(self.videoRenderer)
        client.videoCapturer?.startCapture()
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardVideoTrack track: RTCVideoTrack) {
        track.remove(self.videoRenderer)
        client.videoCapturer?.stopCapture()
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error) {
        self.showDialog(title: NSLocalizedString("error.title", comment: ""),
                        message: error.localizedDescription,
                        cancelButtonTitle: NSLocalizedString("error.ok", comment: ""))
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didChangeConnectionState state: RTCIceConnectionState) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didReceiveVideoTracks tracks: [RTCVideoTrack]) {
        let viewControllers = self.makeViewControllers(peerId: peer.identifier, videoTracks: tracks)
        self.viewControllers.append(contentsOf: viewControllers)
        
        self.pageViewController?.setViewControllers([self.viewControllers[self.currentPageIndex]],
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, peer: ASPeer, didDiscardVideoTracks tracks: [RTCVideoTrack]) {
        for item in self.viewControllerItems(of: tracks) {
            self.viewControllers.remove(at: item.offset)
        }
        let viewControllers: [UIViewController]
        
        if let viewController = self.viewControllers.first {
            viewControllers = [viewController]
        } else {
            viewControllers = []
        }
        
        self.pageViewController?.setViewControllers(viewControllers,
                                                    direction: .reverse,
                                                    animated: true,
                                                    completion: nil)
        self.currentPageIndex = 0
    }
}
