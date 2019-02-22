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
    }
    
    private let storage = UserDefaults.standard
    
    // MARK: - Public properties

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
    
    // MARK: - Initialization
    
    public init() {}
}
