//
//  ASVideoEncoderFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 05/07/2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASVideoEncoderFactory: RTCVideoEncoderFactoryH264 {
    
    // MARK: - Access methods
    
    override public func createEncoder(_ info: RTCVideoCodecInfo) -> RTCVideoEncoder? {
        if info.name == kRTCVp8CodecName {
            return RTCVideoEncoderVP8.vp8Encoder()
        }
        return super.createEncoder(info)
    }
    
    override public func supportedCodecs() -> [RTCVideoCodecInfo] {
        return super.supportedCodecs() + [RTCVideoCodecInfo(name: kRTCVp8CodecName)]
    }
}
