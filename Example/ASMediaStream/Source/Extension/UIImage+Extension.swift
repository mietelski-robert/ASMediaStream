//
//  UIImage+Extension.swift
//  Soou.me
//
//  Created by Robert Mietelski on 09.07.2018.
//  Copyright © 2018 altconnect. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIImage {
    func setTintColor(_ tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let rect = CGRect(origin: .zero, size: self.size)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.setBlendMode(.normal)
        UIColor.black.setFill()
        context.fill(rect)
        
        // draw original image
        context.setBlendMode(.normal)
        context.draw(self.cgImage!, in: rect)
        
        // tint image (loosing alpha) - the luminosity of the original image is preserved
        context.setBlendMode(.multiply)
        tintColor.setFill()
        context.fill(rect)
        
        // mask by alpha values of original image
        context.setBlendMode(.destinationIn)
        context.draw(self.cgImage!, in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
