//
//  JSONAdapter.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 27.08.2018.
//  Copyright © 2018 altconnect. All rights reserved.
//

import Foundation

open class JSONAdapter {
    
    // MARK: - Private attributes
    
    private var dateFormatter = DateFormatter()
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
        
        return decoder
    }
    
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(self.dateFormatter)
        
        return encoder
    }
    
    // MARK: - Initialization
    
    init(dateFormat: String = "yyyy-MM-dd'T'HH:mmZ") {
        self.dateFormatter.dateFormat = dateFormat
    }
    
    // MARK: - Access methods
    
    public func decodeToArray<R: Decodable>(from json: Any) throws -> [R] {
        let data = try JSONSerialization.data(withJSONObject: json)
        let remoteList = try data.decoded(using: self.decoder) as [R]
        
        return remoteList
    }
    
    public func decodeToObject<R: Decodable>(from json: [String: Any]) throws -> R {
        let data = try JSONSerialization.data(withJSONObject: json)
        let object = try data.decoded(using: self.decoder) as R
        
        return object
    }
    
    public func encodeToJSON<R: Encodable>(from object: R) throws -> [String: Any] {
        if let json = try JSONSerialization.jsonObject(with: try JSONEncoder().encode(object)) as? [String: Any] {
            return json
        }
        return [:]
    }
}
