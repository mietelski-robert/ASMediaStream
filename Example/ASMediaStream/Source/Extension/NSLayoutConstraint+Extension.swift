//
//  NSLayoutConstraint+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 29.11.2017.
//  Copyright © 2017 Comarch S.A. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    public static func build(item view1: Any,
                             attribute attr1: NSLayoutAttribute,
                             relatedBy relation: NSLayoutRelation = .equal,
                             toItem view2: Any? = nil,
                             attribute attr2: NSLayoutAttribute = .notAnAttribute,
                             multiplier: CGFloat = 1.0,
                             constant: CGFloat = 0.0,
                             priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: view1,
                                            attribute: attr1,
                                            relatedBy: relation,
                                            toItem: view2,
                                            attribute: attr2,
                                            multiplier: multiplier,
                                            constant: constant)
        
        constraint.priority = priority
        return constraint
    }
}
