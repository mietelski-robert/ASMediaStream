//
//  RoomTextInputViewCell.swift
//  ASMediaStream_Example
//
//  Created by Robert Mietelski on 12.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import UIKit

protocol RoomTextInputViewCellDelegate: class {
    func roomTextInputViewCell(_ cell: RoomTextInputViewCell, shouldJoinRoomWithName name: String)
}

class RoomTextInputViewCell: UITableViewCell {

    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    weak var delegate: RoomTextInputViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupLabels()
        self.setupTextField()
        self.setupJoinButton()
    }
}

extension RoomTextInputViewCell {
    private func setupLabels() {
        self.roomLabel.text = "Proszę wprowadzić nazwę pokoju."
    }
    
    private func setupTextField() {
        self.roomTextField.delegate = self
        self.roomTextField.returnKeyType = .done
    }
    
    private func setupJoinButton() {
        self.joinButton.addTarget(self, action: #selector(joinButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        self.joinButton.layer.borderWidth = 1.0
        self.joinButton.layer.borderColor = UIColor.black.cgColor
        self.joinButton.layer.cornerRadius = 5.0
    }
}

extension RoomTextInputViewCell {
    @objc private func joinButtonPressed(_ sender: UIButton) {
        self.delegate?.roomTextInputViewCell(self, shouldJoinRoomWithName: self.roomTextField.text ?? "")
    }
}

extension RoomTextInputViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
