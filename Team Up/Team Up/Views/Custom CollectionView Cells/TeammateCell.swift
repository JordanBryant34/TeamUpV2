//
//  TeammateCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/29/20.
//

import UIKit

protocol TeammateCellDelegate: AnyObject {
    func messageButtonTapped(cell: TeammateCell)
    func moreButtonTapped(cell: TeammateCell)
}

extension TeammateCellDelegate {
    func messageButtonTapped() { /* empty default implementation */ }
    func moreButtonTapped() { /* empty default implementation */ }
}

class TeammateCell: UICollectionViewCell {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 17)
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.backgroundColor = .teamUpBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7.5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "messageIcon")?.resize(newSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        button.tintColor = .accent()
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.setImage(templateImage, for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "moreOptions")?.resize(newSize: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysTemplate)
        button.imageEdgeInsets = UIEdgeInsets(top: 3.5, left: 3.5, bottom: 3.5, right: 3.5)
        button.tintColor = .accent()
        button.setImage(templateImage, for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let playingNowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .boldSystemFont(ofSize: 14)
        label.isHidden = true
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var user: User? {
        didSet {
            setData()
        }
    }
    
    var delegate: TeammateCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        messageButton.addTarget(self, action: #selector(handleMessageButtonTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(handleMoreButtonTapped), for: .touchUpInside)
                
        setupViews()
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        backgroundColor = .teamUpDarkBlue()
        
        addSubview(profilePicImageView)
        addSubview(usernameLabel)
        addSubview(horizontalStackView)
        addSubview(verticalStackView)
        
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: frame.height * 0.75, width: frame.height * 0.75)
        profilePicImageView.layer.cornerRadius = frame.height * 0.375
        
        horizontalStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        horizontalStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        horizontalStackView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        verticalStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 10).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: horizontalStackView.leftAnchor, constant: -10).isActive = true
        
        moreButton.setHeightAndWidthConstants(height: 35, width: 35)
        messageButton.setHeightAndWidthConstants(height: 35, width: 35)
        
        horizontalStackView.addArrangedSubview(messageButton)
        horizontalStackView.addArrangedSubview(moreButton)
        
        verticalStackView.addArrangedSubview(usernameLabel)
        verticalStackView.addArrangedSubview(playingNowLabel)
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let user = user else { return }
        
        usernameLabel.text = user.username
        
        let imageDimension = frame.height * 0.75
        UserController.fetchProfilePicture(picUrl: user.profilePicUrl) { [weak self] (image) in
            self?.profilePicImageView.image = image.resize(newSize: CGSize(width: imageDimension, height: imageDimension))
        }
        
        playingNowLabel.isHidden = user.currentlyPlaying == nil
        playingNowLabel.text = "Playing \(user.currentlyPlaying ?? "")"
    }
    
    @objc private func handleMessageButtonTapped() {
        delegate?.messageButtonTapped(cell: self)
    }
    
    @objc private func handleMoreButtonTapped() {
        delegate?.moreButtonTapped(cell: self)
    }
    
}
