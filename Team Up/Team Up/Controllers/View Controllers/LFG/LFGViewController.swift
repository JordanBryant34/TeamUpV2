//
//  LFGViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseDatabase
import NVActivityIndicatorView

class LFGViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
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
        label.alpha = 0
        label.textColor = .white
        return label
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let gameController = GameController.shared
    var users: [User] = []
    var resultGames: [Game] = []
    
    let cellId = "cellId"
    let usersCellId = "userCellId"
    let headerId = "headerId"
    let titleHeaderId = "titleHeaderId"

    var searchText: String?
    
    var gamesDataSource: [Game] {
        if let searchText = searchText, !searchText.isEmpty {
            return resultGames
        } else {
            return gameController.games
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(UserSearchControllerCell.self, forCellWithReuseIdentifier: usersCellId)
        collectionView.register(TitleAndSearchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: titleHeaderId)
        
        getGames()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeNavigationBarClear()
        updateViewsByScrollPosition(scrollView: collectionView)
    }
    
    private func setupViews() {
        navigationItem.titleView = titleLabel
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        collectionView.pinEdgesToView(view: view)
        
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: (10/16)).isActive = true
        
        backgroundImageView.image = UIImage(named: "lfgBackground")?.resize(newSize: CGSize(width: view.frame.width, height: view.frame.width * (10/16)))
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    private func getGames() {
        activityIndicator.startAnimating()
        gameController.fetchAllGames { [weak self] (games) in
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func reloadSection(sections: [Int]) {
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(sections))
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LFGViewController: UserSearchDelegate {
    func presentUserProfile(username: String) {
        let profileVC = ProfileViewController()
        profileVC.username = username
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

extension LFGViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
        self.perform(#selector(search), with: nil, afterDelay: 0.5)
        
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != searchText {
            search()
        }
        
        dismissKeyboard()
    }
    
    @objc private func search() {
        
        if let searchText = searchText, !searchText.isEmpty {
            resultGames = gameController.searchGames(searchText: searchText)
            
            UserController.searchUsers(searchText: searchText) { [weak self] (users) in
                self?.users = users
                self?.reloadSection(sections: [1, 2])
            }
        } else {
            resultGames = []
            users = []
            reloadSection(sections: [1, 2])
        }
    
    }
    
}

extension LFGViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            if users.count > 0 {
                return 1
            } else {
                return 0
            }
        } else if section == 2 {
            return gamesDataSource.count
        } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GameCell
            let game = gamesDataSource[indexPath.item]
            
            cell.game = game
            
            return cell
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: usersCellId, for: indexPath) as! UserSearchControllerCell
            
            cell.users = self.users
            cell.delegate = self
            
            return cell
        } else {
            return UICollectionViewCell(frame: .zero)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! TitleAndSearchHeader
            
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

            header.searchBar.delegate = self
            header.searchBar.text = searchText
            header.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search LFG...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
            
            header.titleLabel.text = "Looking for group"
            header.detailLabel.text = "Tap on a game to find people that also play that game."
            
            return header
        } else if indexPath.section == 1 || indexPath.section == 2 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: titleHeaderId, for: indexPath) as! LargeTitleHeader
            var dataSource: [Any] = []
            
            if indexPath.section == 1 {
                dataSource = users
                header.titleLabel.text = dataSource.count > 0 ? "Users" : "No users found"
            } else if indexPath.section == 2 {
                dataSource = gamesDataSource
                header.titleLabel.text = dataSource.count > 0 ? "Games" : "No games found"
            }
            
            header.titleLabel.font = dataSource.count > 0 ? .boldSystemFont(ofSize: 30) : .systemFont(ofSize: 25)
            header.titleLabel.textColor = dataSource.count > 0 ? .white : .secondaryLabelColor()
            
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
            
            return header
        } else {
            return UICollectionReusableView(frame: .zero)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let gameCellWidth = view.frame.width - 20
        let gameCellHeight = gameCellWidth * (9/16) - 30
        
        if indexPath.section == 1 {
            return CGSize(width: view.frame.width, height: 150)
        } else if indexPath.section == 2 {
            return CGSize(width: gameCellWidth, height: gameCellHeight)
        } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: view.frame.width * (9/16))
        case 1, 2:
            let size = !(searchText?.isEmpty ?? true) ? CGSize(width: view.frame.width, height: 50) : .zero
            return size
        default:
            return .zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissKeyboard()
        
        if indexPath.section == 2 {
            let game = gamesDataSource[indexPath.item]
            
            let playersViewController = PlayersViewController()
            playersViewController.game = game

            navigationController?.pushViewController(playersViewController, animated: true)
        }
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
        
        if offsetForNavBar < 0 {
            navigationItem.titleView = nil
            offsetForNavBar = 0
        } else {
            navigationItem.titleView = titleLabel
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
        
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? TitleAndSearchHeader {
            header.titleLabel.alpha = 1 - offsetForLabels
            header.detailLabel.alpha = 1 - offsetForLabels
            header.searchBar.alpha = 1 - offsetForSearchBar
        }
    
        backgroundImageView.alpha = 1 - offsetForImage
    }
    
}
