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
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var game: Game? {
        didSet {
            setData()
        }
    }
    
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
        
        backgroundImageView.pinEdgesToView(view: self)
        
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
        logoImageView.setHeightAndWidthConstants(height: 75, width: 75)
        
        gameNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        gameNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        gameNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        gameNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4).isActive = true
    }
    
    private func setData() {
        backgroundImageView.image = nil
        
        guard let game = game else { return }
        
        gameNameLabel.text = game.name
        
        print("\(game.name): \(game.backgroundImageUrl)")
        
        GameController.fetchGameBackground(game: game) { [weak self] (image) in
            self?.backgroundImageView.image = image
        }
        
        GameController.fetchGameLogo(game: game) { [weak self] (image) in
            guard let newImage = image?.resize(newSize: CGSize(width: 75, height: 75)) else { return }
            self?.logoImageView.image = newImage
        }
        
    }
    
}
