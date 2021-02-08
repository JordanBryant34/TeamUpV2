//
//  ChatViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/5/20.
//

import UIKit
import NVActivityIndicatorView

class ChatViewController: UIViewController {
    
    let chatContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.separatorStyle = .none
        tableView.alpha = 0
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let chatInputView: ChatInputView = {
        let view = ChatInputView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var chat: DirectChat?
    var messageController = MessageController.shared
    
    var chatContainerBottomConstraint: NSLayoutConstraint?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupViews()
        setupObserversAndActions()
        
        if let chat = chat, !chat.messages.isEmpty {
            activityIndicator.startAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom(animated: false)
    }
    
    private func setupObserversAndActions() {
        let tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapToDismissKeyboard)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChat), name: Notification.Name("messagesUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        chatInputView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    private func setupViews() {
        
        if let chat = chat {
            title = chat.chatPartner.username
            navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue()), for: .default)
            navigationController?.navigationBar.isTranslucent = false
        }
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(chatContainer)
        
        chatContainer.addSubview(tableView)
        chatContainer.addSubview(chatInputView)
        chatContainer.addSubview(activityIndicator)
        
        chatContainer.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: view.frame.height)
        chatContainerBottomConstraint = chatContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        chatContainerBottomConstraint?.isActive = true
        
        chatInputView.anchor(nil, left: chatContainer.leftAnchor, bottom: chatContainer.bottomAnchor, right: chatContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 55)
        
        tableView.anchor(chatContainer.topAnchor, left: chatContainer.leftAnchor, bottom: chatInputView.topAnchor, right: chatContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    @objc private func updateChat() {
        if let chatPartner = chat?.chatPartner {
            chat = messageController.fetchDirectChat(chatParter: chatPartner)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        }
    }
    
    @objc private func sendMessage() {        
        if let text = chatInputView.textField.text, let chat = chat, !text.isEmpty {
            messageController.sendDirectMessage(messageText: text, chatPartner: chat.chatPartner)
            chatInputView.textField.text = ""
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        guard let messages = self.chat?.messages, !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) {
            self.tableView.alpha = 1
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        if let tabBarHeight = tabBarController?.tabBar.frame.height {
            chatContainerBottomConstraint?.constant = -keyboardFrame.height + tabBarHeight
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
                self.scrollToBottom(animated: false)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        chatContainerBottomConstraint?.constant = 0
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print("\n\nChatViewController Deinit\n\n")
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MessageTableViewCell
        let message = chat?.messages[indexPath.row]
        
        if indexPath.row > 0 {
            cell.hideUsername = message?.fromUser == chat?.messages[indexPath.row - 1].fromUser
        } else {
            cell.hideUsername = false
        }
        
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
