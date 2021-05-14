//
//  PlayerCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

protocol PlayerCellDelegate: AnyObject {
    func requestTapped(user: User, cell: PlayerCell)
}

class PlayerCell: UICollectionViewCell {
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 30
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.backgroundColor = .teamUpBlue()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpBlue()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let regionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .boldSystemFont(ofSize: 14)
        label.sizeToFit()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let platformImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabelColor()
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let micImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .secondaryLabelColor()
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7.5
        return stackView
    }()
    
    private let requestButton: UIButton = {
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
    
    private let playingNowLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "Playing now"
        label.isHidden = true
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playingNowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "playingNowIcon")?.resize(newSize: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .secondaryLabelColor()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    weak var delegate: PlayerCellDelegate?
    let iconImageSize = CGSize(width: 20, height: 20)
    
    var alreadyRequested = false {
        didSet {
            requestButton.isEnabled = !alreadyRequested
        }
    }
    
    var user: User? {
        didSet {
            setData()
        }
    }
    
    var game: Game?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        requestButton.addTarget(self, action: #selector(handleRequestButtonTapped), for: .touchUpInside)
        
        setupViews()
    }
    
    private func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        backgroundColor = .teamUpDarkBlue()
        
        addSubview(profilePicImageView)
        addSubview(separatorView)
        addSubview(stackView)
        addSubview(requestButton)
        addSubview(playingNowImageView)
        addSubview(playingNowLabel)
        
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
        
        requestButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true
        requestButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        requestButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        requestButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(regionLabel)
        stackView.addArrangedSubview(platformImageView)
        stackView.addArrangedSubview(micImageView)
        
        playingNowImageView.leftAnchor.constraint(equalTo: separatorView.leftAnchor).isActive = true
        playingNowImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: frame.height / 4).isActive = true
        playingNowImageView.setHeightAndWidthConstants(height: 20, width: 20)
        
        playingNowLabel.leftAnchor.constraint(equalTo: playingNowImageView.rightAnchor, constant: 5).isActive = true
        playingNowLabel.centerYAnchor.constraint(equalTo: playingNowImageView.centerYAnchor).isActive = true
    }
    
    private func setData() {
        profilePicImageView.image = nil
        
        guard let user = user else { return }
        
        usernameLabel.text = user.username
        regionLabel.text = user.region.rawValue
        micImageView.image = UIImage(named: user.mic.rawValue)?.resize(newSize: iconImageSize).withRenderingMode(.alwaysTemplate)
        platformImageView.image = UIImage(named: "\(user.platform ?? " ")Icon")?.resize(newSize: iconImageSize).withRenderingMode(.alwaysTemplate)
        
        UserController.fetchProfilePicture(picUrl: user.profilePicUrl) { [weak self] (image) in
            self?.profilePicImageView.image = image.resize(newSize: CGSize(width: 60, height: 60))
        }
        
        let playingNow = (game?.name ?? "") == user.currentlyPlaying
        playingNowLabel.isHidden = !playingNow
        playingNowImageView.isHidden = !playingNow
    }
    
    @objc private func handleRequestButtonTapped() {
        guard let user = user, let delegate = delegate else { return }
        delegate.requestTapped(user: user, cell: self)
    }
    
}
