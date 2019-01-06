//
//  RoomViewController.swift
//  WebRTCExample
//
//  Created by Robert Mietelski on 12.12.2018.
//  Copyright © 2018 Robert Mietelski. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "RoomTextInputViewCellIdentifier"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? VideoViewController, let roomName = sender as? String else {
            return
        }
        viewController.roomName = roomName
    }
}

extension RoomViewController {
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 260.0
        self.tableView.separatorStyle = .none
    }
}

extension RoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? RoomTextInputViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
}

extension RoomViewController: UITableViewDelegate {

}

extension RoomViewController: RoomTextInputViewCellDelegate {
    func roomTextInputViewCell(_ cell: RoomTextInputViewCell, shouldJoinRoomWithName name: String) {
        self.performSegue(withIdentifier: "VideoViewController", sender: name)
    }
}
