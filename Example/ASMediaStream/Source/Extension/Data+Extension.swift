//
//  Data+Extension.swift
//  ASMediaStream_Example
//
//  Created by Jakub Kurgan on 22.08.2018.
//  Copyright © 2018 altconnect. All rights reserved.
//

import Foundation

extension Data {
    func decoded<T:Decodable>(using decoder: AnyDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(T.self, from: self)
    }
}

protocol AnyDecoder {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: AnyDecoder {}
