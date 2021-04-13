//
//  MessageTableViewCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/5/20.
//

import UIKit
import FirebaseAuth

class MessageTableViewCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .systemFont(ofSize: 15)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageBubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpDarkBlue()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separatorColor().cgColor
        return view
    }()
    
    var message: Message? {
        didSet {
            setData()
        }
    }
    
    var hideUsername = false
    
    var nameLabelLeftAnchor: NSLayoutConstraint?
    var nameLabelRightAnchor: NSLayoutConstraint?
    
    var messageLabelRightAnchor: NSLayoutConstraint?
    var messageLabelLeftAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageBubbleView)
        contentView.addSubview(messageLabel)
        
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        nameLabelRightAnchor = nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        nameLabelLeftAnchor = nameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20)
        
        messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        messageLabel.preferredMaxLayoutWidth = frame.width * 0.75
        
        messageLabelRightAnchor = messageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        messageLabelLeftAnchor = messageLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20)
        
        messageBubbleView.anchor(messageLabel.topAnchor, left: messageLabel.leftAnchor, bottom: messageLabel.bottomAnchor, right: messageLabel.rightAnchor, topConstant: -10, leftConstant: -10, bottomConstant: -10, rightConstant: -10, widthConstant: 0, heightConstant: 0)
    }
    
    private func setData() {
        guard let message = message else { return }
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        messageLabel.text = message.text
        nameLabel.text = hideUsername ? "" : message.fromUser
        
        let isFromCurrentUser = message.fromUser == currentUser
        
        nameLabelRightAnchor?.isActive = isFromCurrentUser
        nameLabelLeftAnchor?.isActive = !isFromCurrentUser
        
        messageLabelRightAnchor?.isActive = isFromCurrentUser
        messageLabelLeftAnchor?.isActive = !isFromCurrentUser
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
