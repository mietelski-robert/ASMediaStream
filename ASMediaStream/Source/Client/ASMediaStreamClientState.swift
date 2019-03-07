//
//  ASMediaStreamClientState.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public enum ASMediaStreamClientState: Int {
    case disconnected, connecting, connected, reconnecting
}
