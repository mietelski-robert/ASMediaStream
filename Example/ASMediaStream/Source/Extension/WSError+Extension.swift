//
//  WSError+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Starscream

extension WSError: LocalizedError {
    public var errorDescription: String? {
        return self.message
    }
}
