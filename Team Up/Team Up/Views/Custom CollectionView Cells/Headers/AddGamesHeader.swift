//
//  AddGamesHeader.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/22/20.
//

import UIKit

class AddGamesHeader: UICollectionReusableView {
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Games...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        searchBar.backgroundColor = .clear
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = UIColor.teamUpDarkBlue().withAlphaComponent(0.8)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    let addGamesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Add games you play"
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.text = "Tap on a game and choose what platform you play on."
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
        addSubview(addGamesLabel)
        addSubview(detailLabel)
        
        searchBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        searchBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addGamesLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -30).isActive = true
        addGamesLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        detailLabel.topAnchor.constraint(equalTo: addGamesLabel.bottomAnchor, constant: 10).isActive = true
        detailLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        detailLabel.preferredMaxLayoutWidth = frame.width * 0.55
    }
}
