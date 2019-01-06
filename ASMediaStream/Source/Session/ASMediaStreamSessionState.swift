//
//  ASMediaStreamSessionState.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public enum ASMediaStreamSessionState {
    case open
    case joined(roomMembers: Int)
    case closed
}

extension ASMediaStreamSessionState: Equatable {
    public static func ==(lhs: ASMediaStreamSessionState, rhs: ASMediaStreamSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.open, .open):
            return true
        case (.joined(let value1), .joined(let value2)):
            return value1 == value2
        case (.closed, .closed):
            return true
        default:
            return false
        }
    }
}
