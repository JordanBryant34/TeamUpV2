//
//  AddGamesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/20/20.
//

import UIKit
import FirebaseAuth

class AddGamesViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addGamesBackground")
        imageView.alpha = 0.1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let gameController = GameController.shared
    
    var dataSource: [Game]  {
        if let searchText = searchText, !searchText.isEmpty {
            return searchResults
        } else {
            return gameController.games
        }
    }
    
    var searchResults: [Game] = []
    
    var addedGames: [Game] = []
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    var searchText: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(AddGamesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        makeNavigationBarClear()
        fetchGames()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func fetchGames() {
        if gameController.games.count == 0 {
            gameController.fetchAllGames { [weak self] (games) in
                self?.reloadData()
            }
        }
        
        if let username = Auth.auth().currentUser?.displayName {
            UserController.fetchUsersGames(username: username) { [weak self] (games) in
                self?.addedGames = games
                self?.reloadData()
            }
        }
    }
    
    private func setupViews() {
        title = "Add Games"
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        
        backgroundImageView.pinEdgesToView(view: view)
        collectionView.pinEdgesToView(view: view)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(finishTapped))
    }
    
    private func presentPlatformOptions(game: Game, indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Select the platform you play on.", message: nil, preferredStyle: .actionSheet)
        
        for platform in game.platforms {
            let action = UIAlertAction(title: platform, style: .default) { [weak self] (_) in
                let image = UIImage(named: "\(platform)Icon")?.resize(newSize: CGSize(width: 30, height: 30))
                
                let gameToAdd = game
                gameToAdd.playerPlatform = platform
                self?.addedGames.append(gameToAdd)
                
                self?.reloadCell(at: indexPath)
                
                Helpers.showNotificationBanner(title: "Game added!", subtitle: "You've added \(game.name) to your profile.", image: image, style: .success, textAlignment: .left)
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentRemoveOption(game: Game, indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Remove \(game.name) from your games?", message: nil, preferredStyle: .alert)
        
        let removeAction = UIAlertAction(title: "Remove", style: .default) { [weak self] (_) in
            if let index = self?.addedGames.firstIndex(of: game) {
                game.playerPlatform = nil
                self?.addedGames.remove(at: index)
            }
            
            self?.reloadCell(at: indexPath)
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(removeAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func finishTapped() {
        UserController.updateGames(games: addedGames)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
    
    private func reloadCell(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    deinit {
        print("\n\nAddGamesViewController Deinit\n\n")
    }
    
}

extension AddGamesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return dataSource.count
        } else { return 0 }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? GameCell,
              indexPath.section == 1 else { return UICollectionViewCell() }
        let game = dataSource[indexPath.item]
                
        cell.isEditing = true
        
        if addedGames.contains(game), let index = addedGames.firstIndex(of: game) {
            cell.game = addedGames[index]
        } else {
            cell.game = game
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as? AddGamesHeader, indexPath.section == 0 else { return UICollectionReusableView(frame: .zero) }
        
        header.searchBar.searchTextField.text = searchText
        
        header.searchBar.delegate = self
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
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
            return CGSize(width: view.frame.width, height: view.frame.height / 3)
        } else { return .zero }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        let game = dataSource[indexPath.item]
        
        if addedGames.contains(game) {
            presentRemoveOption(game: game, indexPath: indexPath)
        } else {
            presentPlatformOptions(game: dataSource[indexPath.item], indexPath: indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 2.5)
        var offsetForLabels = scrollView.contentOffset.y / (view.frame.height * 0.075)
        var offsetForSearchBar = scrollView.contentOffset.y / (view.frame.height * 0.2)
        
        if offsetForNavBar > 0.9 {
            offsetForNavBar = 0.95
        }
        
        if offsetForLabels > 1 {
            offsetForLabels = 1
        }
        
        if offsetForSearchBar > 1 {
            offsetForSearchBar = 1
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue().withAlphaComponent(offsetForNavBar)), for: .default)
        
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? AddGamesHeader {
            header.addGamesLabel.alpha = 1 - offsetForLabels
            header.detailLabel.alpha = 1 - offsetForLabels
            header.searchBar.alpha = 1 - offsetForSearchBar
        }
    }
    
}

extension AddGamesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        searchResults = gameController.searchGames(searchText: searchText)
        
        self.reloadData()
    }
    
}
