//
//  ASMediaStreamClientError+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import ASMediaStream

extension ASMediaStreamClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .enableVideoFailed:
            return "Nie udało się włączyć aparatu"
        case .disableVideoFailed:
            return "Nie udało się wyłączyć aparatu"
        case .enableAudioFailed:
            return "Nie udało się włączyć mikrofonu"
        case .disableAudioFailed:
            return "Nie udało się wyłączyć mikrofonu"
        case .joiningRoomFailed:
            return "Nie udało się nawiązać połączenia"
        case .openingChannelFailed:
            return "Nie udało się otworzyć kanału wymiany danych"
        }
    }
}
