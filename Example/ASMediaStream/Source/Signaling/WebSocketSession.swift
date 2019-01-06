//
//  WebSocketSession.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import ASMediaStream
import Starscream
import WebRTC

class WebSocketSession: NSObject {

    // MARK: - Public attributes
    
    private(set) var roomName: String
    private(set) var clientIdentifier: String?
    private(set) var serverUrl: URL
    private(set) var state: ASMediaStreamSessionState = .closed
    
    weak var delegate: ASMediaStreamSessionDelegate?
    
    // MARK: - Private properties
    
    private lazy var socket: WebSocket = {
        let socket = WebSocket(url: self.serverUrl)
        socket.delegate = self
        return socket
    }()
    
    // MARK: - Initialization
    
    required init(roomName: String, serverUrl: URL) {
        self.roomName = roomName
        self.serverUrl = serverUrl
        super.init()
    }
    
    deinit {
        self.leave()
    }
}

// MARK: - Configuration management

extension WebSocketSession {
    private func changeState(to state: ASMediaStreamSessionState) {
        if state != self.state {
            self.state = state
            self.delegate?.mediaStreamSession(self, didChangeState: state)
        }
    }
    
    private func sessionDescription(remote: SessionDescriptionRemote) throws -> RTCSessionDescription {
        guard let type = RTCSdpType(rawValue: remote.type) else {
            throw WebSocketSessionError.unsupportedSessionDescription
        }
        return RTCSessionDescription(type: type, sdp: remote.sdp)
    }
    
    private func candidate(remote: CandidateRemote) -> RTCIceCandidate {
        return RTCIceCandidate(sdp: remote.sdp, sdpMLineIndex: remote.sdpMLineIndex, sdpMid: remote.sdpMid)
    }
}

// MARK: - Message management

extension WebSocketSession {
    private func send(jsonBody: Any, completion: (() -> ())? = nil) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonBody,
                                                      options: JSONSerialization.WritingOptions.prettyPrinted)
            print("JSON Request: \(jsonBody)")
            
            if let message = String(data: jsonData, encoding: String.Encoding.utf8) {
                self.socket.write(string: message, completion: completion)
            } else {
                throw WebSocketSessionError.dataEncodingFailed
            }
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }
}

// MARK: - ASMediaStreamSession

extension WebSocketSession: ASMediaStreamSession {
    func join(completion: (() -> Void)?) {
        do {
            let message = JoinMessageRemote(roomId: self.roomName)
            let jsonBody = try JSONAdapter().encodeToJSON(from: message)
            
            if self.socket.isConnected {
                self.socket.onConnect = nil
                self.send(jsonBody: jsonBody, completion: completion)
            } else {
                self.socket.onConnect = { [weak self] in
                    self?.send(jsonBody: jsonBody, completion: completion)
                }
                self.socket.connect()
            }
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }
    
    func leave() {
        guard self.socket.isConnected else {
            return
        }
        self.socket.disconnect()
    }
    
    func send(_ request: ASSessionDescriptionRequest, completion: (() -> Void)?) {
        do {
            let sessionDescription = SessionDescriptionRemote(domain: request.sessionDescription)
            let content = SessionDescriptionContentRemote(sessionDescription: sessionDescription)
            let message: SessionDescriptionMessageRemote
            
            if let receiverId = request.receiverId {
                message = SessionDescriptionMessageRemote(roomId: self.roomName,
                                                          senderId: self.clientIdentifier,
                                                          receiverId: receiverId,
                                                          content: content)
            } else {
                message = SessionDescriptionMessageRemote(roomId: self.roomName,
                                                          senderId: self.clientIdentifier,
                                                          content: content)
            }
            
            let jsonBody = try JSONAdapter().encodeToJSON(from: message)
            self.send(jsonBody: jsonBody, completion: completion)
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }
    
    func send(_ request: ASCandidateRequest, completion: (() -> Void)?) {
        do {
            let candidate = CandidateRemote(domain: request.candidate)
            let content = CandidateContentRemote(candidate: candidate)
            let message: CandidateMessageRemote
            
            if let receiverId = request.receiverId {
                message = CandidateMessageRemote(roomId: self.roomName,
                                                 senderId: self.clientIdentifier,
                                                 receiverId: receiverId,
                                                 content: content)
            } else {
                message = CandidateMessageRemote(roomId: self.roomName,
                                                 senderId: self.clientIdentifier,
                                                 content: content)
            }
            
            let jsonBody = try JSONAdapter().encodeToJSON(from: message)
            self.send(jsonBody: jsonBody, completion: completion)
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }
}

// MARK: - ASMediaStreamSession

extension WebSocketSession: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        self.changeState(to: .open)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let error = error {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        } else {
            self.changeState(to: .closed)
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            guard let data = text.data(using: .utf8) else {
                throw WebSocketSessionError.dataDecodingFailed
            }
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            print("JSON Response: \(jsonObject)")
            
            if let messageDictionary = jsonObject as? [String: Any], let contentDictionary = messageDictionary["content"] as? [String: Any] {
                let senderId = messageDictionary["senderId"] as? String
                let rawValue = messageDictionary["type"] as? String
                
                switch WebSocketMessageTypeRemote(optionalValue: rawValue) {
                case .join:
                    let content: JoinContentRemote = try JSONAdapter().decodeToObject(from: contentDictionary)
                    self.clientIdentifier = senderId
                    self.changeState(to: .joined(roomMembers: content.roomMembers))
                case .broadcast, .message:
                    let rawValue = contentDictionary["type"] as? String
                    
                    switch WebSocketContentTypeRemote(optionalValue: rawValue) {
                    case .sessionDescription:
                        let content: SessionDescriptionContentRemote = try JSONAdapter().decodeToObject(from: contentDictionary)
                        let sessionDescription = try self.sessionDescription(remote: content.sessionDescription)
                        let response = ASSessionDescriptionResponse(senderId: senderId, sessionDescription: sessionDescription)
                        
                        self.delegate?.mediaStreamSession(self, didReceiveSessionDescriptionResponse: response)
                    case .candidate:
                        let content: CandidateContentRemote = try JSONAdapter().decodeToObject(from: contentDictionary)
                        let candidate = self.candidate(remote: content.candidate)
                        let response = ASCandidateResponse(senderId: senderId, candidate: candidate)
                        
                        self.delegate?.mediaStreamSession(self, didReceiveCandidateResponse: response)
                    case .unknown:
                        throw WebSocketSessionError.unsupportedMessage
                    }
                case .unknown:
                    throw WebSocketSessionError.unsupportedMessage
                }
            } else {
                throw WebSocketSessionError.unsupportedMessage
            }
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}
