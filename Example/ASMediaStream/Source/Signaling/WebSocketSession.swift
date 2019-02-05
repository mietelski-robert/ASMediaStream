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
    
    private(set) var serverUrl: URL
    private(set) var roomName: String
    private(set) var parameters: [String: Any]
    private(set) var peerId: String?
    private(set) var state: ASMediaStreamSessionState = .closed
    
    weak var delegate: ASMediaStreamSessionDelegate?
    
    // MARK: - Private properties
    
    private lazy var socket: WebSocket = {
        let socket = WebSocket(url: self.serverUrl)
        socket.delegate = self
        return socket
    }()
    
    // MARK: - Initialization
    
    required init(serverUrl: URL, roomName: String, parameters: [String: Any] = [:]) {
        self.serverUrl = serverUrl
        self.roomName = roomName
        self.parameters = parameters
        
        super.init()
        self.registerNotifications()
    }
    
    deinit {
        self.leave()
        self.unregisterNotifications()
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
            throw WebSocketSessionError.unsupportedConfigurationReceived
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
                throw WebSocketSessionError.encodingDataFailed
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
            guard let senderId = self.peerId else {
                throw WebSocketSessionError.sendingConfigurationFailed
            }
            
            let sessionDescription = SessionDescriptionRemote(domain: request.sessionDescription)
            let content = SessionDescriptionContentRemote(sessionDescription: sessionDescription)
            let message: SessionDescriptionMessageRemote
            
            if let receiverId = request.receiverId {
                message = SessionDescriptionMessageRemote(roomId: self.roomName,
                                                          senderId: senderId,
                                                          receiverId: receiverId,
                                                          content: content)
            } else {
                message = SessionDescriptionMessageRemote(roomId: self.roomName,
                                                          senderId: senderId,
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
            guard let senderId = self.peerId else {
                throw WebSocketSessionError.sendingConfigurationFailed
            }
            
            let candidate = CandidateRemote(domain: request.candidate)
            let content = CandidateContentRemote(candidate: candidate)
            let message: CandidateMessageRemote
            
            if let receiverId = request.receiverId {
                message = CandidateMessageRemote(roomId: self.roomName,
                                                 senderId: senderId,
                                                 receiverId: receiverId,
                                                 content: content)
            } else {
                message = CandidateMessageRemote(roomId: self.roomName,
                                                 senderId: senderId,
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
        if let error = error as? WSError, error.code == CloseCode.normal.rawValue {
            self.changeState(to: .closed)
        } else if self.state == .open {
            self.changeState(to: .closed)
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            guard let data = text.data(using: .utf8) else {
                throw WebSocketSessionError.decodingDataFailed
            }
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            print("JSON Response: \(jsonObject)")
            
            if let messageDictionary = jsonObject as? [String: Any], let contentDictionary = messageDictionary["content"] as? [String: Any] {
                let rawValue = messageDictionary["type"] as? String
                
                switch WebSocketMessageTypeRemote(optionalValue: rawValue) {
                case .join:
                    let message: JoinMessageRemote = try JSONAdapter().decodeToObject(from: messageDictionary)
                    let members = message.content?.roomMemberIds ?? []
                    
                    self.peerId = message.senderId
                    self.changeState(to: .joined(members: members))
                case .broadcast, .message:
                    let rawValue = contentDictionary["type"] as? String
                    
                    switch WebSocketContentTypeRemote(optionalValue: rawValue) {
                    case .sessionDescription:
                        let message: SessionDescriptionMessageRemote = try JSONAdapter().decodeToObject(from: messageDictionary)
                        let sessionDescription = try self.sessionDescription(remote: message.content.sessionDescription)
                        let response = ASSessionDescriptionResponse(senderId: message.senderId, sessionDescription: sessionDescription)
                        
                        self.delegate?.mediaStreamSession(self, didReceiveSessionDescriptionResponse: response)
                    case .candidate:
                        let message: CandidateMessageRemote = try JSONAdapter().decodeToObject(from: messageDictionary)
                        let candidate = self.candidate(remote: message.content.candidate)
                        let response = ASCandidateResponse(senderId: message.senderId, candidate: candidate)
                        
                        self.delegate?.mediaStreamSession(self, didReceiveCandidateResponse: response)
                    case .unknown:
                        throw WebSocketSessionError.unsupportedMessageReceived
                    }
                case .unknown:
                    throw WebSocketSessionError.unsupportedMessageReceived
                }
            } else {
                throw WebSocketSessionError.unsupportedMessageReceived
            }
        } catch {
            self.delegate?.mediaStreamSession(self, didFailWithError: error)
        }
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
}

// MARK: - Notifications

extension WebSocketSession {
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(notification:)),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive ,
                                               object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                  object: nil)
    }
    
    @objc private func applicationDidBecomeActive(notification: NSNotification) {
        guard !self.socket.isConnected, self.state != .closed else {
            return
        }
        self.changeState(to: .reconnecting)
        self.join()
    }
}
