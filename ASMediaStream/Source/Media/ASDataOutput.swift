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
    
    public var clientId: String?
    public var data: Data
    
    // MARK: - Initialization
    
    public init(clientId: String? = nil, data: Data) {
        self.clientId = clientId
        self.data = data
    }
}
