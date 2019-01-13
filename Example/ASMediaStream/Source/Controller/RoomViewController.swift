//
//  RoomViewController.swift
//  WebRTCExample
//
//  Created by Robert Mietelski on 12.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import UIKit

class RoomViewController: ViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWrapperView()
        self.setupLabel()
        self.setupTextField()
        self.setupJoinButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unregisterNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else {
            return
        }
        let rootViewController = navigationController.viewControllers.first
        
        if let viewController = rootViewController as? VideoPagerViewController, let roomName = sender as? String {
            viewController.roomName = roomName
        }
    }
}

extension RoomViewController {
    private func setupWrapperView() {
        self.wrapperView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        self.wrapperView.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        self.wrapperView.layer.cornerRadius = 15.0
        self.wrapperView.layer.borderWidth = 1.0
        self.wrapperView.layer.masksToBounds = true
    }
        
    private func setupLabel() {
        self.roomLabel.text = NSLocalizedString("join.roomName", comment: "")
        self.roomLabel.textAlignment = .center
        self.roomLabel.textColor = UIColor.white
        self.roomLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
    }
    
    private func setupTextField() {
        self.roomTextField.placeholder = NSLocalizedString("join.roomNamePlaceholder", comment: "")
        self.roomTextField.delegate = self
        self.roomTextField.returnKeyType = .done
        self.roomTextField.layer.borderWidth = 1.0
        self.roomTextField.layer.cornerRadius = 15.0
        self.roomTextField.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.roomTextField.textAlignment = .center
        self.roomTextField.backgroundColor = UIColor.clear
        self.roomTextField.textColor = UIColor.white
        self.roomTextField.layer.borderColor = UIColor.white.cgColor
    }
    
    private func setupJoinButton() {
        self.joinButton.addTarget(self, action: #selector(joinButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        self.joinButton.setTitle(NSLocalizedString("join.submit", comment: ""), for: UIControlState.normal)
        self.joinButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.joinButton.layer.cornerRadius = 15.0
        self.joinButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.joinButton.layer.masksToBounds = true
    }
}

extension RoomViewController {
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    private func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        self.scrollView.contentInset.bottom = keyboardRect.cgRectValue.size.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset.bottom = 0.0
    }
}

extension RoomViewController {
    @objc private func joinButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "VideoPagerViewController", sender: self.roomTextField.text ?? "")
    }
}

extension RoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
