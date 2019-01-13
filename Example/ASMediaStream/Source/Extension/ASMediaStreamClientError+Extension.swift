//
//  ASMediaStreamClientError+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import ASMediaStream

extension ASMediaStreamClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .enableVideoFailed:
            return NSLocalizedString("error.enableVideoFailed", comment: "")
        case .disableVideoFailed:
            return NSLocalizedString("error.disableVideoFailed", comment: "")
        case .enableAudioFailed:
            return NSLocalizedString("error.enableAudioFailed", comment: "")
        case .disableAudioFailed:
            return NSLocalizedString("error.disableAudioFailed", comment: "")
        case .joiningRoomFailed:
            return NSLocalizedString("error.joiningRoomFailed", comment: "")
        case .openingChannelFailed:
            return NSLocalizedString("error.openingChannelFailed", comment: "")
        case .sendingDataFailed:
            return NSLocalizedString("error.sendingDataFailed", comment: "")
        }
    }
}
