//
//  ProfileHeader.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/31/20.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    let bannerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let profilePicOutlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpBlue()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 55
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpBlue()
        return view
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separatorColor().withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .boldSystemFont(ofSize: 14)
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let micImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabelColor()
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7.5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        addSubview(bannerView)
        addSubview(backgroundView)
        addSubview(profilePicOutlineView)
        addSubview(profilePicImageView)
        addSubview(bioLabel)
        addSubview(separatorView)
        addSubview(dividerView)
        addSubview(stackView)
        
        bannerView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.width * 0.4)
        
        profilePicImageView.centerYAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 15).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: 100, width: 100)
        
        profilePicOutlineView.centerInView(view: profilePicImageView)
        profilePicOutlineView.setHeightAndWidthConstants(height: 110, width: 110)
        
        bioLabel.topAnchor.constraint(equalTo: profilePicImageView.bottomAnchor).isActive = true
        bioLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bioLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bioLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -30).isActive = true
        
        separatorView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        
        backgroundView.anchor(bannerView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        dividerView.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 50).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        dividerView.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 10).isActive = true
        
        stackView.bottomAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: -15).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 15).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(regionLabel)
        stackView.addArrangedSubview(micImageView)
        
        micImageView.setHeightAndWidthConstants(height: 20, width: 20)
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let user = user else { return }
        
        UserController.fetchProfilePicture(picUrl: user.profilePicUrl) { [weak self] (image) in
            self?.profilePicImageView.image = image.resize(newSize: CGSize(width: 100, height: 100))
        }
        
        bioLabel.text = user.bio
        usernameLabel.text = user.username
        regionLabel.text = user.region.rawValue
        
        micImageView.image = UIImage(named: user.mic.rawValue)?.resize(newSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
    }
}
