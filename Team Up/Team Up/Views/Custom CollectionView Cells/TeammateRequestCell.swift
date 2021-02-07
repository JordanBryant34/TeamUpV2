//
//  TeammateRequestCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/29/20.
//

import UIKit

protocol TeammateRequestCellDelegate: AnyObject {
    func acceptRequest(requestingUser: User, cell: TeammateRequestCell)
    func declineRequest(requestingUser: User, cell: TeammateRequestCell)
}

class TeammateRequestCell: UICollectionViewCell {
    
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
    
    let acceptButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "checkmark")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .accent()
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let declineButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "xIcon")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        button.tintColor = .systemRed
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var user: User? {
        didSet {
            setData()
        }
    }
    
    weak var delegate: TeammateRequestCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        
        setupViews()
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        backgroundColor = .teamUpDarkBlue()
        
        addSubview(profilePicImageView)
        addSubview(usernameLabel)
        addSubview(declineButton)
        addSubview(acceptButton)
        
        profilePicImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profilePicImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profilePicImageView.setHeightAndWidthConstants(height: frame.height * 0.75, width: frame.height * 0.75)
        profilePicImageView.layer.cornerRadius = frame.height * 0.375
        
        usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: profilePicImageView.rightAnchor, constant: 15).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: acceptButton.leftAnchor, constant: -10).isActive = true
        usernameLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        declineButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        declineButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        declineButton.setHeightAndWidthConstants(height: 35, width: 35)
        
        acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: declineButton.leftAnchor, constant: -20).isActive = true
        acceptButton.setHeightAndWidthConstants(height: 35, width: 35)
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let user = user else { return }
        
        usernameLabel.text = user.username
        
        let imageDimension = frame.height * 0.75
        UserController.fetchProfilePicture(picUrl: user.profilePicUrl) { [weak self] (image) in
            self?.profilePicImageView.image = image.resize(newSize: CGSize(width: imageDimension, height: imageDimension))
        }
    }
    
    @objc private func acceptButtonTapped() {
        guard let user = user else { return }
        delegate?.acceptRequest(requestingUser: user, cell: self)
    }
    
    @objc private func declineButtonTapped() {
        guard let user = user else { return }
        delegate?.declineRequest(requestingUser: user, cell: self)
    }
}
