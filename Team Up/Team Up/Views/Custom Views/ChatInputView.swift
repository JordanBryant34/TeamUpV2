//
//  ChatInputView.swift
//  Team Up
//
//  Created by Jordan Bryant on 11/6/20.
//

import UIKit

class ChatInputView: UIView {
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.accent(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        return button
    }()
    
    let textField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        textField.backgroundColor = .teamUpBlue()
        textField.placeholder = "Message..."
        return textField
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(sendButton)
        addSubview(textField)
        
        sendButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 80, heightConstant: 0)
        
        textField.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: sendButton.leftAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    
        backgroundColor = .teamUpDarkBlue()
    }
    
}
