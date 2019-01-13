//
//  ASVideoCapturerError+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 11.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import ASMediaStream

extension ASVideoCapturerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .torchUnavailable:
            return NSLocalizedString("error.torchUnavailable", comment: "")
        }
    }
}
