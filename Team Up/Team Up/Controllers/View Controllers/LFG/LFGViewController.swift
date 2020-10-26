//
//  LFGViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class LFGViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.text = "Looking for group"
        label.alpha = 1
        label.textColor = .white
        return label
    }()
    
    let gameController = GameController.shared
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LFGHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        getGames()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        makeNavigationBarClear()
        updateViewsByScrollPosition(scrollView: collectionView)
    }
    
    private func setupViews() {
        navigationItem.titleView = titleLabel
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        
        collectionView.pinEdgesToView(view: view)
        
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: (10/16)).isActive = true
        
        backgroundImageView.image = UIImage(named: "lfgBackground")?.resize(newSize: CGSize(width: view.frame.width, height: view.frame.width * (10/16)))
    }
    
    private func getGames() {
        gameController.fetchAllGames { [weak self] (games) in
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension LFGViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return gameController.games.count
        } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? GameCell,
              indexPath.section == 1 else { return UICollectionViewCell() }
        let game = gameController.games[indexPath.item]
        
        cell.game = game
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as? LFGHeader, indexPath.section == 0 else { return UICollectionReusableView(frame: .zero) }
  
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height = width * (9/16) - 30
        
        if indexPath.section == 1 {
            return CGSize(width: width, height: height)
        } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.width, height: view.frame.width * (9/16))
        } else { return .zero }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateViewsByScrollPosition(scrollView: scrollView)
    }
    
    private func updateViewsByScrollPosition(scrollView: UIScrollView) {
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 2.5)
        var offsetForLabels = scrollView.contentOffset.y / (view.frame.height * 0.075)
        var offsetForSearchBar = scrollView.contentOffset.y / (view.frame.height * 0.2)
        var offsetForImage = scrollView.contentOffset.y / (view.frame.height * 0.2)
        
        if offsetForNavBar > 0.95 {
            offsetForNavBar = 0.95
        }
        
        if offsetForLabels > 1 {
            offsetForLabels = 1
        }
        
        if offsetForSearchBar > 1 {
            offsetForSearchBar = 1
        }
        
        if offsetForImage < 0.4 {
            offsetForImage = 0.4
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue().withAlphaComponent(offsetForNavBar)), for: .default)
        titleLabel.alpha = offsetForNavBar
        
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? LFGHeader {
            header.titleLabel.alpha = 1 - offsetForLabels
            header.detailLabel.alpha = 1 - offsetForLabels
            header.searchBar.alpha = 1 - offsetForSearchBar
        }
    
        backgroundImageView.alpha = 1 - offsetForImage
    }
    
}
