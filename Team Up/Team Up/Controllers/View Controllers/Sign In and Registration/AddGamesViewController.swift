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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchGames()
        setupViews()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height = width * (9/16) - 30
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(games[indexPath.item].name)
    }
    
}
