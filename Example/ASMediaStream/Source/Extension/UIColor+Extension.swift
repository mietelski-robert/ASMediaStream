//
//  ASMediaStreamClientError+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 04.01.2019.
//  Copyright © 2019 Robert Mietelski. All rights reserved.
//

import UIKit

extension UIColor {
    func image(size: CGSize = CGSize(width: 1, height: 1), radius: CGFloat = 0.0) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { (context) in
            let clipPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: radius).cgPath
            
            context.cgContext.addPath(clipPath)
            context.cgContext.setFillColor(self.cgColor)
            
            context.cgContext.closePath()
            context.cgContext.fillPath()
        }
    }
}
