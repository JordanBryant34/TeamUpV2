//
//  CurrentGameCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/30/21.
//

import UIKit

class CurrentGameCell: UICollectionViewCell {
    
    private let gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 7.5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .boldSystemFont(ofSize: 22.5)
        label.textColor = .white
        label.text = "You're online"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabelColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var game: Game? {
        didSet {
            setData()
        }
    }
    
    private var gameController = GameController.shared
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .teamUpDarkBlue()
        layer.masksToBounds = true
        layer.cornerRadius = 15
        
        addSubview(gameImageView)
        addSubview(titleLabel)
        addSubview(subLabel)
        
        gameImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        gameImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        gameImageView.setHeightAndWidthConstants(height: 70, width: 70)
        
        titleLabel.bottomAnchor.constraint(equalTo: gameImageView.centerYAnchor, constant: -1).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: gameImageView.rightAnchor, constant: 10).isActive = true
        
        subLabel.topAnchor.constraint(equalTo: gameImageView.centerYAnchor, constant: 4).isActive = true
        subLabel.leftAnchor.constraint(equalTo: gameImageView.rightAnchor, constant: 10).isActive = true
        subLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        subLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func setData() {
        if let game = game {
            subLabel.text = "Playing \(game.name)"
            
            gameController.fetchGameLogo(game: game) { [weak self] (image) in
                guard let newImage = image?.resize(newSize: CGSize(width: 70, height: 70)) else { return }
                self?.gameImageView.image = newImage
            }
        }
    }
    
}

