//
//  WebSocketContentTypeRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

enum WebSocketContentTypeRemote: String, Codable {
    case sessionDescription = "SESSION_DESCRIPTION"
    case candidate = "CANDIDATE"
    case unknown
    
    init(optionalValue: String?) {
        self = WebSocketContentTypeRemote(rawValue: optionalValue ?? "") ?? .unknown
    }
}
