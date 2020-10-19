//
//  RoundedButton.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class RoundedButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
