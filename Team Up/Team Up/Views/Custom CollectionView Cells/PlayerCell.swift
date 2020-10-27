//
//  PlayerCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "ImJordanBryant"
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.backgroundColor = .teamUpBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpBlue()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "Australia"
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let platformImageView: UIImageView = {
        let imageView = UIImageView()
        let templateImage = UIImage(named: "XboxIcon")?.resize(newSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        imageView.image = templateImage
        imageView.tintColor = .secondaryLabelColor()
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    let micImageView: UIImageView = {
        let imageView = UIImageView()
        let templateImage = UIImage(named: "mic")?.resize(newSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysTemplate)
        imageView.image = templateImage
        imageView.tintColor = .secondaryLabelColor()
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7.5
        return stackView
    }()
    
    let teamUpButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .accent()
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.setTitle("Request", for: .normal)
        button.setTitle("Requested", for: .disabled)
        button.setTitleColor(.accent(), for: .normal)
        button.setTitleColor(.secondaryLabelColor(), for: .disabled)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let moreButton: UIButton = {
        let button = UIButton()
        let templateImage = UIImage(named: "moreOptions")?.resize(newSize: CGSize(width: 30, height: 30)).withRenderingMode(.alwaysTemplate)
        button.tintColor = .accent()
        button.setBackgroundImage(templateImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        backgroundColor = .teamUpDarkBlue()
        
        addSubview(profilePicImageView)
        addSubview(separatorView)
        addSubview(stackView)
        addSubview(teamUpButton)
        addSubview(moreButton)
        
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: 60, width: 60)
        
        separatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        separatorView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separatorView.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 10).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        stackView.anchor(topAnchor, left: separatorView.leftAnchor, bottom: separatorView.topAnchor, right: rightAnchor, topConstant: 12.5, leftConstant: 0, bottomConstant: 12.5, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        platformImageView.setHeightAndWidthConstants(height: 20, width: 20)
        micImageView.setHeightAndWidthConstants(height: 20, width: 20)
        
        teamUpButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        teamUpButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        teamUpButton.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -10).isActive = true
        teamUpButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        moreButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 7.5).isActive = true
        moreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7.5).isActive = true
        moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(regionLabel)
        stackView.addArrangedSubview(platformImageView)
        stackView.addArrangedSubview(micImageView)
    }
}
