//
//  CurrentGameCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/30/21.
//

import UIKit

class CurrentGameCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .teamUpDarkBlue()
    }
    
}

