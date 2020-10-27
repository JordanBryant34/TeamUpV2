//
//  AttributeLabel.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

class AttributeLabel: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.accent().cgColor
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(label)
        
        label.centerInView(view: self)
        
        widthAnchor.constraint(equalTo: label.widthAnchor, constant: 15).isActive = true
    }
}
