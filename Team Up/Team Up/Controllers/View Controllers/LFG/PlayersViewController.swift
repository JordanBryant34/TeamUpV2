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
    
    lazy var filtersBarButtonItem: UIBarButtonItem = {
        let image = UIImage(named: "filtersIcon")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(filtersTapped), for: .touchUpInside)
        
        let filterBarButton = UIBarButtonItem(customView: button)
        return filterBarButton
    }()
    
    var game: Game?
    let cellId = "cellId"
    let headerId = "headerId"
    
    var users: [User] = []
    var requestedUsers: [User] = []
    
    let gameController = GameController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.register(PlayerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
            
        setupViews()
        fetchPlayers(platform: nil, region: nil)
        makeNavigationBarClear()
    }
    
    private func setupViews() {
        navigationItem.titleView = titleLabel
        navigationItem.rightBarButtonItem = filtersBarButtonItem
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: (10/16)).isActive = true
        
        filtersBarButtonItem.customView?.setHeightAndWidthConstants(height: 35, width: 35)
                
        collectionView.pinEdgesToView(view: view)
        
        if let game = game {
            titleLabel.text = game.name
            gameController.fetchGameBackground(game: game) { [weak self] (image) in
                self?.backgroundImageView.image = image
            }
        }
    }
    
    private func fetchPlayers(platform: String?, region: Region?) {
        guard let game = game else { return }
        LFGController.fetchPlayers(game: game, platform: platform, region: region) { [weak self] (users) in
            self?.users = users
            
            self?.reloadData()
        }
    }
    
    @objc private func filtersTapped() {
        let filtersVC = LFGFiltersViewController()
        filtersVC.game = game
        filtersVC.delegate = self
        filtersVC.modalPresentationStyle = .overFullScreen
        present(filtersVC, animated: true, completion: nil)
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func reloadCells(indexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: indexPath)
        }
    }
    
    deinit {
        print("\n\nPlayersViewController Deinit\n\n")
    }
    
}

extension PlayersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PlayerCell
        let user = users[indexPath.item]

        cell.delegate = self
        cell.user = user
        cell.alreadyRequested = requestedUsers.contains(user)
        
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

extension PlayersViewController: LFGFiltersViewControllerDelegate {
    func filter(platform: String?, region: Region?) {
        fetchPlayers(platform: platform, region: region)
    }
}

extension PlayersViewController: PlayerCellDelegate {
    func requestTapped(user: User, cell: PlayerCell) {
        LFGController.requestPlayerToTeamUp(user: user) { [weak self] (success) in
            if success {
                self?.requestedUsers.append(user)
                cell.alreadyRequested = true
            }
        }
    }
}
