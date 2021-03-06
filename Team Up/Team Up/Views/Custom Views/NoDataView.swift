//
//  NoDataView.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/30/20.
//

import UIKit

class NoDataView: UIView {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .secondaryLabelColor()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let button: RoundedButton = {
        let button = RoundedButton()
        button.backgroundColor = .accent()
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(detailTextLabel)
        addSubview(button)
        
        imageView.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 15).isActive = true
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.setHeightAndWidthConstants(height: frame.width * 0.5, width: frame.width * 0.5)
        
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
        textLabel.preferredMaxLayoutWidth = frame.width * 0.75
        
        detailTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        detailTextLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 10).isActive = true
        detailTextLabel.preferredMaxLayoutWidth = frame.width * 0.75
        
        button.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: detailTextLabel.bottomAnchor, constant: 40).isActive = true
        button.setHeightAndWidthConstants(height: 60, width: frame.width * 0.6)
    }
    
}
