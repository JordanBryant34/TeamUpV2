//
//  NoLobbyCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/24/21.
//

import UIKit

class NoLobbyCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .red
    }
    
}
