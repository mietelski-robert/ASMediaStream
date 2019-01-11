//
//  VideoPagerViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 07.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ASMediaStream
import WebRTC
import PromiseKit

class VideoPagerViewController: UIViewController {

    // MARK: - Public properties
    
    var roomName: String = ""
    
    // MARK: - Private properties
    
    private var pageViewController: UIPageViewController?
    private var currentPageIndex: Int = 0
    
    private var viewControllers: [UIViewController] = []
    
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
        self.setupPageControl()
        
        firstly {
            self.videoAuthorizationRequest()
        } .then { _ in
            self.audioAuthorizationRequest()
        } .done { _ in
            self.client = ASMediaStreamClient(iceServers: [self.stunServer], sessionFactory: WebSocketSessionFactory())
            self.client?.delegate = self
            self.client?.connectToRoom(name: self.roomName)
        } .catch { error in
            self.showDialog(title: "Wystąpił błąd", message: error.localizedDescription, cancelButtonTitle: "Ok")
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
}

// MARK: - Setup

extension VideoPagerViewController {
    private func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(dismissViewController))
    }
    
    private func setupPageControl() {
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
    }
}

// MARK: - Page management

extension VideoPagerViewController {
    private func videoPageViewController(clientId: String?, videoTrack: RTCVideoTrack?) -> UIViewController {
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "VideoPageViewControllerIdentifier")
        
        if let videoPageViewController = viewController as? VideoPageViewController {
            videoPageViewController.videoTrack = videoTrack
            videoPageViewController.clientId = clientId
            videoPageViewController.delegate = self
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
    
    private func makeViewControllers(with output: ASVideoOutput) -> [UIViewController] {
        return output.videoTracks.map { self.videoPageViewController(clientId: output.clientId, videoTrack: $0) }
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

// MARK: - VideoPageViewControllerDelegate

extension VideoPagerViewController: VideoPageViewControllerDelegate {
    func videoPageViewControllerSwitchCamera(in viewController: VideoPageViewController) {
        if let clientId = viewController.clientId {
            
        } else {
            self.client?.videoCapturer?.switchCamera()
        }
    }
    
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeVideoEnabled isEnabled: Bool) {
        if let clientId = viewController.clientId {
            let data = "test".data(using: .utf8)
            self.client?.sendData(data!, clientId: clientId)
        } else {
            
        }
    }
    
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeAudioEnabled isEnabled: Bool) {

    }
    
    func videoPageViewController(_ viewController: VideoPageViewController, didChangeFlashlightState isOn: Bool) {

    }
}

// MARK: - ASMediaStreamClientDelegate

extension VideoPagerViewController: ASMediaStreamClientDelegate {
    func mediaStreamClient(_ client: ASMediaStreamClient, didChangeState state: ASMediaStreamClientState) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalVideo output: ASVideoOutput) {
        let viewControllers = self.makeViewControllers(with: output)
        self.viewControllers.append(contentsOf: viewControllers)
        
        self.pageViewController?.setViewControllers([self.viewControllers[self.currentPageIndex]],
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
        client.videoCapturer?.startCapture()
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalVideo output: ASVideoOutput) {
//        for item in self.viewControllerItems(of: output.videoTracks) {
//            self.viewControllers.remove(at: item.offset)
//        }
//        client.videoCapturer?.stopCapture()
//
//        let viewControllers: [UIViewController]
//
//        if let viewController = self.viewControllers.first {
//            viewControllers = [viewController]
//        } else {
//            viewControllers = []
//        }
//
//        self.pageViewController?.setViewControllers(viewControllers,
//                                                    direction: .reverse,
//                                                    animated: true,
//                                                    completion: nil)
//        self.currentPageIndex = 0
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveLocalAudio output: ASAudioOutput) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardLocalAudio output: ASAudioOutput) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteVideo output: ASVideoOutput) {
        let viewControllers = self.makeViewControllers(with: output)
        self.viewControllers.append(contentsOf: viewControllers)

        self.pageViewController?.setViewControllers([self.viewControllers[self.currentPageIndex]],
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteVideo output: ASVideoOutput) {
//        for item in self.viewControllerItems(of: output.videoTracks) {
//            self.viewControllers.remove(at: item.offset)
//        }
//        let viewControllers: [UIViewController]
//
//        if let viewController = self.viewControllers.first {
//            viewControllers = [viewController]
//        } else {
//            viewControllers = []
//        }
//
//        self.pageViewController?.setViewControllers(viewControllers,
//                                                    direction: .reverse,
//                                                    animated: true,
//                                                    completion: nil)
//        self.currentPageIndex = 0
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveRemoteAudio output: ASAudioOutput) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didDiscardRemoteAudio output: ASAudioOutput) {
        
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didReceiveData output: ASDataOutput) {
        self.showDialog(title: "Otrzymano wiadomość", message: String(data: output.data, encoding: .utf8)!, cancelButtonTitle: "Ok")
    }
    
    func mediaStreamClient(_ client: ASMediaStreamClient, didFailWithError error: Error) {
        self.showDialog(title: "Wystąpił błąd", message: error.localizedDescription, cancelButtonTitle: "Ok")
    }
}
