//
//  LargeTitleTableViewHeader.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/3/20.
//

import UIKit

class LargeTitleTableViewHeader: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 37.5)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        titleLabel.preferredMaxLayoutWidth = frame.width * 0.9
    }
    
}
