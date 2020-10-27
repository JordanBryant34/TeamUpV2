//
//  UserSearchCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/27/20.
//

import UIKit

class UserSearchCell: UICollectionViewCell {
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.text = "ImJordanBryant"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var user: User? {
        didSet {
            setData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(profilePicImageView)
        addSubview(usernameLabel)
        
        let imageDimension = frame.height * 0.45
        profilePicImageView.layer.cornerRadius = imageDimension / 2
        profilePicImageView.setHeightAndWidthConstants(height: imageDimension, width: imageDimension)
        profilePicImageView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        profilePicImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        usernameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profilePicImageView.bottomAnchor).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        usernameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
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
    
}
