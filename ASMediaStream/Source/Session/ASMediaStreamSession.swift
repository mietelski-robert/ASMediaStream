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
    
    var roomName: String { get }
    var peerId: String? { get }
    var serverUrl: URL { get }
    var state: ASMediaStreamSessionState { get }
    
    var delegate: ASMediaStreamSessionDelegate? { set get }
    
    // MARK: - Initialization
    
    init(roomName: String, serverUrl: URL)
    
    // MARK: - Access methods
    
    func join(parameters: [String: Any], completion: (() -> Void)?)
    func leave()
    
    func send(_ request: ASSessionDescriptionRequest, completion: (() -> Void)?)
    func send(_ request: ASCandidateRequest, completion: (() -> Void)?)
}

public extension ASMediaStreamSession {
    func join(parameters: [String: Any]) {
        self.join(parameters: parameters, completion: nil)
    }
    
    func send(_ request: ASSessionDescriptionRequest) {
        self.send(request, completion: nil)
    }
    
    func send(_ request: ASCandidateRequest) {
        self.send(request, completion: nil)
    }
}
