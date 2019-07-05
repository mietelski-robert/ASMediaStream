//
//  ViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 13.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Public properties
    
    var backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "background")
        
        return imageView
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.insertSubview(self.backgroundImageView, at: 0)
        
        self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    }
}
