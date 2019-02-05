//
//  ASMediaStreamSessionFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public protocol ASMediaStreamSessionFactory: class {

    // MARK: - Access methods
    
    func makeSession(roomName: String, parameters: [String: Any], delegate: ASMediaStreamSessionDelegate?) -> ASMediaStreamSession
}
