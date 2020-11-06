//
//  TeamUpTextField.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class TeamUpTextField: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        font = .systemFont(ofSize: 17)
        textColor = .white
        
        autocapitalizationType = .none
        
        layer.masksToBounds = true
        layer.cornerRadius = 7.5
        layer.borderWidth = 1.5
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 10)
    }

}
