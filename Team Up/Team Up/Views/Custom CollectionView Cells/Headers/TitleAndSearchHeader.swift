//
//  TitleAndSearchHeader.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

class TitleAndSearchHeader: UICollectionReusableView {
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = UIColor.teamUpDarkBlue().withAlphaComponent(0.8)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .accent()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(searchBar)
        addSubview(titleLabel)
        addSubview(detailLabel)
        
        searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        searchBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -30).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        detailLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        detailLabel.preferredMaxLayoutWidth = frame.width * 0.55
    }
}
