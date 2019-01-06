//
//  UIViewController+Extension.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 30.11.2018.
//  Copyright © 2018 altconnect. All rights reserved.
//

import UIKit

struct DialogButtonIndex {
    static let cancel: Int? = nil
}

extension UIViewController {
    func showDialog(title: String? = nil,
                    message: String,
                    cancelButtonTitle: String? = nil,
                    otherButtonTitles: [String] = [],
                    presentBlock: (() -> Void)? = nil,
                    dismissBlock: ((Int?) -> Void)? = nil) {
        
        let alertController = self.alertController(title: title,
                                                   message: message,
                                                   cancelButtonTitle: cancelButtonTitle,
                                                   otherButtonTitles: otherButtonTitles,
                                                   dismissBlock: dismissBlock)
        
        self.present(alertController, animated: true, completion: presentBlock)
    }
    
    @objc func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

private extension UIViewController {
    func alertController(title: String?,
                         message: String,
                         cancelButtonTitle: String? = nil,
                         otherButtonTitles: [String],
                         dismissBlock: ((Int?) -> Void)? = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        if let title = cancelButtonTitle {
            alertController.addAction(UIAlertAction(title: title,
                                                    style: .cancel,
                                                    handler: { _ in dismissBlock?(DialogButtonIndex.cancel) } ))
        }
        
        for (index, otherButtonTitle) in otherButtonTitles.enumerated()  {
            let action = UIAlertAction(title: otherButtonTitle,
                                       style: .default,
                                       handler: { (action) in
                                        dismissBlock?(index)
            })
            alertController.addAction(action)
        }
        return alertController
    }
}
