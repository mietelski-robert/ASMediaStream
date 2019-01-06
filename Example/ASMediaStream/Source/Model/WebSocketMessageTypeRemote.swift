//
//  WebSocketMessageTypeRemote.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

enum WebSocketMessageTypeRemote: String, Codable {
    case join = "JOIN"
    case broadcast = "BROADCAST"
    case message = "MESSAGE"
    case unknown
    
    init(optionalValue: String?) {
        self = WebSocketMessageTypeRemote(rawValue: optionalValue ?? "") ?? .unknown
    }
}
