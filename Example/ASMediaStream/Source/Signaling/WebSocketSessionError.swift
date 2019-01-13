//
//  WebSocketSessionError.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

enum WebSocketSessionError: Error {
    case encodingDataFailed
    case decodingDataFailed
    case sendingConfigurationFailed
    case unsupportedConfigurationReceived
    case unsupportedMessageReceived
}

extension WebSocketSessionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .encodingDataFailed:
            return NSLocalizedString("error.encodingDataFailed", comment: "")
        case .decodingDataFailed:
            return NSLocalizedString("error.decodingDataFailed", comment: "")
        case .sendingConfigurationFailed:
            return NSLocalizedString("error.sendingConfigurationFailed", comment: "")
        case .unsupportedConfigurationReceived:
            return NSLocalizedString("error.unsupportedConfigurationReceived", comment: "")
        case .unsupportedMessageReceived:
            return NSLocalizedString("error.unsupportedMessageReceived", comment: "")
        }
    }
}
