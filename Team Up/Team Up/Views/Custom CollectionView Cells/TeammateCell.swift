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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let messageButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "messageIcon")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        button.tintColor = .accent()
        button.setBackgroundImage(templateImage, for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "moreOptions")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        button.tintColor = .accent()
        button.setBackgroundImage(templateImage, for: .normal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        addSubview(stackView)
        
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: frame.height * 0.75, width: frame.height * 0.75)
        profilePicImageView.layer.cornerRadius = frame.height * 0.375
        
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 10).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        moreButton.setHeightAndWidthConstants(height: 35, width: 35)
        messageButton.setHeightAndWidthConstants(height: 35, width: 35)
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(messageButton)
        stackView.addArrangedSubview(moreButton)
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let user = user else { return }
        
        usernameLabel.text = user.username
        
        if let imageUrl = URL(string: user.profilePicUrl) {
            ImageService.getImage(withURL: imageUrl) { [weak self] (image) in
                self?.profilePicImageView.image = image
            }
        }
    }
    
    @objc private func handleMessageButtonTapped() {
        delegate?.messageButtonTapped(cell: self)
    }
    
    @objc private func handleMoreButtonTapped() {
        delegate?.moreButtonTapped(cell: self)
    }
    
}
