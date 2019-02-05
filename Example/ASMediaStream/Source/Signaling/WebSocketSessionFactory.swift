//
//  WebSocketSessionFactory.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import ASMediaStream

class WebSocketSessionFactory {

}

// MARK: - ASMediaStreamSessionFactory

extension WebSocketSessionFactory: ASMediaStreamSessionFactory {
    func makeSession(roomName: String, parameters: [String : Any], delegate: ASMediaStreamSessionDelegate?) -> ASMediaStreamSession {
        let serverUrl = URL(string: "ws://host.com")!
        let session = WebSocketSession(serverUrl: serverUrl, roomName: roomName, parameters: parameters)
        session.delegate = delegate
        
        return session
    }
}
