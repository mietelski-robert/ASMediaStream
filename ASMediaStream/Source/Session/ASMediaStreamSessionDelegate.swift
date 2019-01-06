//
//  ASMediaStreamSessionDelegate.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public protocol ASMediaStreamSessionDelegate: class {
    func mediaStreamSession(_ session: ASMediaStreamSession, didChangeState state: ASMediaStreamSessionState)
    func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveSessionDescriptionResponse response: ASSessionDescriptionResponse)
    func mediaStreamSession(_ session: ASMediaStreamSession, didReceiveCandidateResponse response: ASCandidateResponse)
    func mediaStreamSession(_ session: ASMediaStreamSession, didFailWithError error: Error)
}
