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
    func makeSession(roomName: String, delegate: ASMediaStreamSessionDelegate) -> ASMediaStreamSession {
        let serverUrl = URL(string: "ws://192.168.1.140:8082/nanny?access_token=e85233bd-2b85-4dca-8d64-00a5eb9eef45")!
        let session = WebSocketSession(roomName: roomName, serverUrl: serverUrl)
        session.delegate = delegate
        
        return session
    }
}
