//
//  ASDataOutput.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 10.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public struct ASDataOutput {

    // MARK: - Public properties
    
    public var peerId: String?
    public var data: Data
    
    // MARK: - Initialization
    
    public init(peerId: String? = nil, data: Data) {
        self.peerId = peerId
        self.data = data
    }
}
