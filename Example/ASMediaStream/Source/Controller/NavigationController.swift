//
//  NavigationController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 13.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
