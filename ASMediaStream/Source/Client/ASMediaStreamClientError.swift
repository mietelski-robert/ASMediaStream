//
//  ASMediaStreamClientError.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public enum ASMediaStreamClientError: Error {
    case enableVideoFailed
    case disableVideoFailed
    case enableAudioFailed
    case disableAudioFailed
    case joiningRoomFailed
    case openingChannelFailed
}
