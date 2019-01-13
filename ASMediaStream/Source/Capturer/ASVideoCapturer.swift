//
//  ASVideoCapturer.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASVideoCapturer: NSObject {
    
    // MARK: - Private properties
    
    public private(set) var settings: ASVideoSettings
    public private(set) var capturer: RTCCameraVideoCapturer
    public private(set) var position: AVCaptureDevice.Position
    
    public var torchMode: AVCaptureDevice.TorchMode {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else {
            return .off
        }
        return device.torchMode
    }
    
    // MARK: - Initialization
    
    public init(capturer: RTCCameraVideoCapturer, settings: ASVideoSettings = ASVideoSettings(), position: AVCaptureDevice.Position = .front) {
        self.settings = settings
        self.capturer = capturer
        self.position = position
        super.init()
    }
    
    // MARK: - Access methods
    
    public func startCapture() {
        guard let device = self.device(for: self.position) else {
            return
        }
        let format = self.videoFormat(for: device, resolution: self.settings.videoResolution)
        let frameRate = format.videoSupportedFrameRateRanges.map { $0.maxFrameRate }.max { $0 < $1 }
        let fps = Int(frameRate ?? 0.0)
        
        self.capturer.startCapture(with: device, format: format, fps: fps)
    }
    
    public func stopCapture() {
        self.capturer.stopCapture()
    }
    
    public func turnOnTorch() throws {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch, self.position == .back else {
            throw ASVideoCapturerError.torchUnavailable
        }
        try device.lockForConfiguration()
        try device.setTorchModeOn(level: 1.0)
        device.torchMode = .on
        device.unlockForConfiguration()
    }
    
    public func turnOffTorch() throws {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch, self.position == .back else {
            throw ASVideoCapturerError.torchUnavailable
        }
        try device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }
    
    public func switchCamera() {
        if self.position == .front {
            self.position = .back
        } else {
            self.position = .front
        }
        self.stopCapture()
        self.startCapture()
    }
}

// MARK: - Access methods

extension ASVideoCapturer {
    private func device(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let captureDevices = RTCCameraVideoCapturer.captureDevices()
        return captureDevices.first { $0.position == position }
    }
    
    private func videoFormat(for device: AVCaptureDevice, resolution: VideoResolution) -> AVCaptureDevice.Format {
        let targetDimensions = CMVideoDimensions(width: resolution.width, height: resolution.height)
        let supportedFormats = RTCCameraVideoCapturer.supportedFormats(for: device)
        
        var selectedFormat: AVCaptureDevice.Format = supportedFormats[0]
        var currentDiff = INT_MAX
        
        for format in supportedFormats {
            let dimension: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let diff = abs(targetDimensions.width - dimension.width) + abs(targetDimensions.height - dimension.height)
            if diff < currentDiff {
                selectedFormat = format
                currentDiff = diff
            }
        }
        return selectedFormat
    }
}
