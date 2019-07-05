//
//  ASVideoDecoderFactory.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 05/07/2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import WebRTC

public class ASVideoDecoderFactory: RTCVideoDecoderFactoryH264 {
    
    // MARK: - Access methods
    
    override public func createDecoder(_ info: RTCVideoCodecInfo) -> RTCVideoDecoder? {
        if info.name == kRTCVp8CodecName {
            return RTCVideoDecoderVP8.vp8Decoder()
        }
        return super.createDecoder(info)
    }
    
    override public func supportedCodecs() -> [RTCVideoCodecInfo] {
        return super.supportedCodecs() + [RTCVideoCodecInfo(name: kRTCVp8CodecName)]
    }
}
