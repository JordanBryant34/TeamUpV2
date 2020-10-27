//
//  PlayersViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit

class PlayersViewController: UIViewController {
    
    let backgroundImageView: FadedImageView = {
        let imageView = FadedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0.6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.alpha = 0
        label.textColor = .white
        return label
    }()
    
    var game: Game?
    let cellId = "cellId"
    let headerId = "headerId"
    
    let gameController = GameController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(PlayerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
            
        setupViews()
        fetchPlayers()
        makeNavigationBarClear()
    }
    
    private func setupViews() {
        navigationItem.titleView = titleLabel
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: (10/16)).isActive = true
                
        collectionView.pinEdgesToView(view: view)
        
        if let game = game {
            titleLabel.text = game.name
            gameController.fetchGameBackground(game: game) { [weak self] (image) in
                self?.backgroundImageView.image = image
            }
        }
    }
    
    private func fetchPlayers() {
        
    }
    
    deinit {
        print("\n\nPlayersViewController Deinit\n\n")
    }
    
}

extension PlayersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PlayerCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width * 0.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! LargeTitleHeader
        
        if let game = game {
            header.titleLabel.text = game.name
        }
        
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateViewsByScrollPosition(scrollView: scrollView)
    }
    
    private func updateViewsByScrollPosition(scrollView: UIScrollView) {
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 2.5)
        var offsetForLabels = scrollView.contentOffset.y / (view.frame.height * 0.075)
        var offsetForImage = scrollView.contentOffset.y / (view.frame.height * 0.2)
        
        if offsetForNavBar > 0.95 {
            offsetForNavBar = 0.95
        }
        
        if offsetForNavBar < 0 {
            navigationItem.titleView = nil
            offsetForNavBar = 0
        } else {
            navigationItem.titleView = titleLabel
        }
        
        if offsetForLabels > 1 {
            offsetForLabels = 1
        }
        
        if offsetForImage < 0.4 {
            offsetForImage = 0.4
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue().withAlphaComponent(offsetForNavBar)), for: .default)
        titleLabel.alpha = offsetForNavBar
        
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? LargeTitleHeader {
            header.titleLabel.alpha = 1 - offsetForLabels
        }
    
        backgroundImageView.alpha = 1 - offsetForImage
    }
    
}
