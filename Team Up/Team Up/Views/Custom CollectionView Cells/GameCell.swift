//
//  GameCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import UIKit

class GameCell: UICollectionViewCell {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.5
        return imageView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let gameNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.teamUpDarkBlue().withAlphaComponent(0.9)
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.accent().cgColor
        view.layer.cornerRadius = 12.5
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let addedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.text = "Added"
        label.textColor = .accent()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let platformImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var game: Game? {
        didSet {
            setData()
        }
    }
    
    var isEditing = false
    
    let gameController = GameController.shared
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        backgroundColor = .teamUpBlue()
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.accent().cgColor
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backgroundImageView)
        addSubview(logoImageView)
        addSubview(gameNameLabel)
        addSubview(addedView)
        addSubview(platformImageView)
        
        addedView.addSubview(addedLabel)
        
        backgroundImageView.pinEdgesToView(view: self)

        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
        logoImageView.setHeightAndWidthConstants(height: 75, width: 75)

        gameNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        gameNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        gameNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gameNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4).isActive = true
        
        addedView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        addedView.leftAnchor.constraint(equalTo: leftAnchor, constant: -12.5).isActive = true
        addedView.setHeightAndWidthConstants(height: 25, width: 100)
        
        addedLabel.centerYAnchor.constraint(equalTo: addedView.centerYAnchor).isActive = true
        addedLabel.centerXAnchor.constraint(equalTo: addedView.centerXAnchor, constant: 6).isActive = true
        
        platformImageView.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        platformImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        platformImageView.setHeightAndWidthConstants(height: 30, width: 30)
    }
    
    private func setData() {
        backgroundImageView.image = nil
        logoImageView.image = nil
        platformImageView.image = nil
        addedView.isHidden = true
        
        guard let game = game else { return }
        
        gameNameLabel.text = game.name
        
        gameController.fetchGameBackground(game: game) { [weak self] (image) in
            self?.backgroundImageView.image = image
        }
        
        gameController.fetchGameLogo(game: game) { [weak self] (image) in
            guard let newImage = image?.resize(newSize: CGSize(width: 75, height: 75)) else { return }
            self?.logoImageView.image = newImage
        }
        
        if let playerPlatform = game.playerPlatform {
            platformImageView.image = UIImage(named: "\(playerPlatform)Icon")?.resize(newSize: CGSize(width: 30, height: 30))
            
            if isEditing {
                addedView.isHidden = false
            }
        }
    }
    
}
