//
//  ASMediaStreamSession.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public protocol ASMediaStreamSession: class {
    
    // MARK: - Public attributes

    var serverUrl: URL { get }
    var roomName: String { get }
    var parameters: [String: Any] { get }
    var peerId: String? { get }
    var state: ASMediaStreamSessionState { get }
    
    var delegate: ASMediaStreamSessionDelegate? { set get }
    
    // MARK: - Initialization
    
    init(serverUrl: URL, roomName: String, parameters: [String: Any])
    
    // MARK: - Access methods
    
    func join(completion: (() -> Void)?)
    func leave()
    
    func send(_ request: ASSessionDescriptionRequest, completion: (() -> Void)?)
    func send(_ request: ASCandidateRequest, completion: (() -> Void)?)
}

public extension ASMediaStreamSession {
    func join() {
        self.join(completion: nil)
    }
    
    func send(_ request: ASSessionDescriptionRequest) {
        self.send(request, completion: nil)
    }
    
    func send(_ request: ASCandidateRequest) {
        self.send(request, completion: nil)
    }
}
