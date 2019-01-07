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
    case joined(members: [String])
    case closed
}

extension ASMediaStreamSessionState: Equatable {
    public static func ==(lhs: ASMediaStreamSessionState, rhs: ASMediaStreamSessionState) -> Bool {
        switch (lhs, rhs) {
        case (.open, .open):
            return true
        case (.joined(let array1), .joined(let array2)):
            return array1 == array2
        case (.closed, .closed):
            return true
        default:
            return false
        }
    }
}
