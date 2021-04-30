//
//  NoDataCell.swift
//  Team Up
//
//  Created by Jordan Bryant on 4/24/21.
//

import UIKit

class NoDataCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 22.5)
        label.sizeToFit()
        label.textAlignment = .center
        return label
    }()
    
    private let subLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    private let button: RoundedButton = {
        let button = RoundedButton()
        button.backgroundColor = .accent()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        return stackView
    }()
    
    var title: String  = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subText: String = "" {
        didSet {
            subLabel.text = subText
        }
    }
    
    var buttonTitle: String = "" {
        didSet {
            button.setTitle(buttonTitle, for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .teamUpDarkBlue()
        layer.masksToBounds = true
        layer.cornerRadius = 15
                
        addSubview(stackView)
        
        stackView.centerInView(view: self)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subLabel)
        stackView.addArrangedSubview(button)
        
        stackView.setCustomSpacing(10, after: titleLabel)
        
        button.setHeightAndWidthConstants(height: frame.height / 3.25, width: frame.width * 0.8)
        
        subLabel.preferredMaxLayoutWidth = frame.width * 0.75
    }
    
}
