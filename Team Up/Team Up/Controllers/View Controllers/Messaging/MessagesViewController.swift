//
//  MessagesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class MessagesViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    let messageController = MessageController.shared
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("messagesUpdated"), object: nil)
        
        makeNavigationBarClear()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: cellId)
        
        makeNavigationBarClear()
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        tableView.tableFooterView = UIView()
        
        let newMessageButton = UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.rightBarButtonItem = newMessageButton
        
        view.addSubview(tableView)
        
        tableView.pinEdgesToView(view: view)
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func handleNewMessage() {
        let selectTeammateVC = SelectTeammateViewController()
        selectTeammateVC.headerLabelText = "New Message"
        selectTeammateVC.delegate = self
        
        present(UINavigationController(rootViewController: selectTeammateVC), animated: true, completion: nil)
    }
    
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageController.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ChatTableViewCell
        
        cell.chat = messageController.chats[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatController = ChatViewController()
        chatController.chat = messageController.chats[indexPath.item]
        
        navigationController?.pushViewController(chatController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = LargeTitleTableViewHeader()
        header.titleLabel.text = "Messages"
        header.tintColor = .teamUpBlue()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
}

extension MessagesViewController: SelectTeammatesViewControllerDelegate {
    
    func createChat(user: User) {
        let chatController = ChatViewController()
        
        if let chat = messageController.chats.first(where: {$0.chatPartner == user}) {
            chatController.chat = chat
            print("chat already exists")
        } else {
            chatController.chat = DirectChat(chatPartner: user, messages: [])
            print("chat does not already exist")
        }
        
        navigationController?.pushViewController(chatController, animated: true)
    }
}
