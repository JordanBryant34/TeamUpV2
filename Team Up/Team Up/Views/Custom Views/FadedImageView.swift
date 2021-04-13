//
//  FadedImageView.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

class FadedImageView: UIImageView {
    
    private let gradientImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gradientImage")
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(gradientImageView)
        
        gradientImageView.pinEdgesToView(view: self)
    }
}
