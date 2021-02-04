//
//  ProfilePicCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/30/21.
//

import UIKit

class ProfilePicCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.layer.masksToBounds = true
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
        
        imageView.layer.cornerRadius = frame.height / 2
        
        addSubview(imageView)
        
        imageView.pinEdgesToView(view: self)
    }
    
    private func setImage(image: UIImage?) {
        guard let image = image?.resize(newSize: CGSize(width: frame.width, height: frame.height)) else { imageView.image = nil; return }
        
        imageView.image = image
    }
    
}
