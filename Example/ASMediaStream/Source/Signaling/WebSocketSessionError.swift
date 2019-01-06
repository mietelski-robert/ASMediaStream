//
//  WebSocketSessionError.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

enum WebSocketSessionError: Error {
    case receiveMessageFailed(description: String)
    case dataEncodingFailed
    case dataDecodingFailed
    case unsupportedMessage
    case unsupportedSessionDescription
}

extension WebSocketSessionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .receiveMessageFailed(let description):
            return description
        case .dataEncodingFailed:
            return "Nie udało się zakodować wiadomości"
        case .dataDecodingFailed:
            return "Nie udało się odkodować wiadomości"
        case .unsupportedMessage:
            return "Otrzymana wiadomość jest nie obsługiwana"
        case .unsupportedSessionDescription:
            return "Otrzymana konfiguracja sesji jest nie obsługiwana"
        }
    }
}
