//
//  NoLobbyCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/24/21.
//

import UIKit

class NoDataCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You aren't in a lobby."
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 17.5)
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        
    }
    
}
