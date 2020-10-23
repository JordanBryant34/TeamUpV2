//
//  AddGamesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/20/20.
//

import UIKit

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
    
    var games: [Game] = []
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(AddGamesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        setDelegatesAndActions()
        fetchGames()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func setDelegatesAndActions() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func fetchGames() {
        GameController.fetchAllGames { [weak self] (games) in
            self?.games = games
            self?.reloadData()
        }
    }
    
    private func setupViews() {
        title = "Add Games"
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        
        backgroundImageView.pinEdgesToView(view: view)
        collectionView.pinEdgesToView(view: view)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    deinit {
        print("\n\nAddGamesViewController Deinit\n\n")
    }
    
}

extension AddGamesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? GameCell else { return UICollectionViewCell(frame: .zero) }
        cell.game = games[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as? AddGamesHeader else { return UICollectionReusableView(frame: .zero) }
        
        header.searchBar.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height = width * (9/16) - 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(games[indexPath.item].name)
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
        print("Blah Blah")
    }
    
}
