//
//  ProfilePicCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/30/21.
//

import UIKit

class ProfilePicCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.clear.cgColor
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            setImage(image: image)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        
        imageView.layer.cornerRadius = (frame.height - 10) / 2
        
        addSubview(imageView)
        
        imageView.centerInView(view: self)
        imageView.setHeightAndWidthConstants(height: frame.height - 10, width: frame.width - 10)
        
        let selectedView = UIView(frame: bounds)
        selectedView.layer.masksToBounds = false
        selectedView.layer.cornerRadius = frame.height / 2
        selectedView.layer.borderWidth = 5
        selectedView.layer.borderColor = UIColor.accent().cgColor
        selectedView.layer.shadowColor = UIColor.black.cgColor
        selectedView.layer.shadowOffset = .zero
        selectedView.layer.shadowOpacity = 1
        selectedView.layer.shadowRadius = 7.5
        selectedBackgroundView = selectedView
    }
    
    private func setImage(image: UIImage?) {
        guard let image = image?.resize(newSize: CGSize(width: frame.width, height: frame.height)) else { imageView.image = nil; return }
        
        imageView.image = image
    }
    
}
