//
//  ASVideoSettings.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public struct ASVideoSettings {
    
    // MARK: - Private properties
    
    private struct StorageVariablesKeys {
        static let videoResolutionKey = "VideoResolutionKey"
        static let videoCodecKey = "VideoCodecKey"
        static let bitrateKey = "BitrateKey"
    }
    
    private let storage = UserDefaults.standard
    
    // MARK: - Public properties
    
    public enum VideoCodec: String {
        case H264 = "H264"
        case VP8 = "VP8"
        case VP9 = "VP9"
    }
    
    public var videoResolution: VideoResolution {
        get {
            if let resolution = self.storage.object(forKey: StorageVariablesKeys.videoResolutionKey) as? VideoResolution {
                return resolution
            }
            return VideoResolution(width: 640, height: 480)
        }
        set {
            self.storage.set(newValue, forKey: StorageVariablesKeys.videoResolutionKey)
            self.storage.synchronize()
        }
    }
    
    public var videoCodec: VideoCodec {
        get {
            if let rawValue = self.storage.string(forKey: StorageVariablesKeys.videoCodecKey), let videoCodec = VideoCodec(rawValue: rawValue) {
                return videoCodec
            }
            return .H264
        }
        set {
            self.storage.set(newValue.rawValue, forKey: StorageVariablesKeys.videoCodecKey)
            self.storage.synchronize()
        }
    }
    
    public var maxBitrate: NSNumber? {
        get {
            return self.storage.object(forKey: StorageVariablesKeys.bitrateKey) as? NSNumber
        }
        set {
            self.storage.set(newValue, forKey: StorageVariablesKeys.bitrateKey)
            self.storage.synchronize()
        }
    }
    
    // MARK: - Initialization
    
    public init() {}
}
