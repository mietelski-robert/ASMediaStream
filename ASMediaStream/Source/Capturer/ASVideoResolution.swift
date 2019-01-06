//
//  ASVideoResolution.swift
//  ASMediaStream
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import Foundation

public class VideoResolution: NSCoding {
    
    // MARK: - Public properties
    
    public var width: Int32
    public var height: Int32
    
    // MARK: - Initialization
    
    public init(width: Int32, height: Int32) {
        self.width = width
        self.height = height
    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        let width = aDecoder.decodeInt32(forKey: "width")
        let height = aDecoder.decodeInt32(forKey: "height")
        
        self.init(width: width, height: height)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
    }
}
