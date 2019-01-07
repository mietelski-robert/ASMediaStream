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
            return "Nie udało się zakodować wiadomości"
        case .decodingDataFailed:
            return "Nie udało się odkodować wiadomości"
        case .sendingConfigurationFailed:
            return "Nie udało się wysłać konfiguracji połączenia"
        case .unsupportedConfigurationReceived:
            return "Otrzymana konfiguracja połączenia jest nie obsługiwana"
        case .unsupportedMessageReceived:
            return "Otrzymana wiadomość jest nie obsługiwana"
        }
    }
}
