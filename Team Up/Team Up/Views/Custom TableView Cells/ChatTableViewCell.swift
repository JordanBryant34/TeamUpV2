//
//  ChatTableViewCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/3/20.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "ImJordanBryant"
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .white
        return label
    }()
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let chatPreviewLabel: UILabel = {
        let label = UILabel()
        label.text = "This is test preview text that is supposed to displayed in the chat cell."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabelColor()
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "5 minutes ago"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabelColor()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var chat: DirectChat? {
        didSet {
            setData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .teamUpDarkBlue()
        self.selectedBackgroundView = backgroundView
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
            
        backgroundColor = .teamUpBlue()
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(profilePicImageView)
        addSubview(usernameLabel)
        addSubview(chatPreviewLabel)
        addSubview(timeLabel)
        
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: 60, width: 60)
        
        usernameLabel.anchor(profilePicImageView.topAnchor, left: profilePicImageView.rightAnchor, bottom: centerYAnchor, right: timeLabel.leftAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        chatPreviewLabel.anchor(centerYAnchor, left: profilePicImageView.rightAnchor, bottom: profilePicImageView.bottomAnchor, right: timeLabel.leftAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let chat = chat else { return }
        
        usernameLabel.text = chat.chatPartner.username
        
        if let imageUrl = URL(string: chat.chatPartner.profilePicUrl) {
            ImageService.getImage(withURL: imageUrl) { [weak self] (image) in
                self?.profilePicImageView.image = image
            }
        }
        
        if !chat.messages.isEmpty {
            chatPreviewLabel.text = chat.messages[0].text
        }
        
        let messageDate = Date(timeIntervalSince1970: Double(chat.messages[0].timestamp))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        let relativeDate = formatter.localizedString(for: messageDate, relativeTo: Date())
        timeLabel.text = relativeDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
