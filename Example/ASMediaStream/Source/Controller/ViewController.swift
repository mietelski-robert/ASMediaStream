//
//  ViewController.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 13.01.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

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
        
        self.backgroundImageView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.snp.edges)
        }
    }
}
