//
//  ProfileViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView

class ProfileViewController: UIViewController {
    
    let backgroundImageView: FadedImageView = {
        let imageView = FadedImageView()
        imageView.alpha = 0.8
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never
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
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var user: User?
    var username: String?
    
    var currentUser = false
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        makeNavigationBarClear()
        
        if user == nil {
            fetchUser()
        } else {
            fetchBackgroundImage()
        }
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeNavigationBarClear()
        updateViewsByScrollPosition(scrollView: collectionView)
    }
    
    private func setupViews() {
        
        view.backgroundColor = .teamUpBlue()
        
        navigationItem.titleView = titleLabel
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.setHeightAndWidthConstants(height: view.frame.width * (10/16), width: view.frame.width)
        
        collectionView.pinEdgesToView(view: view)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    private func fetchBackgroundImage() {
        guard let randomGame = user?.games.randomElement() else { return }
        GameController.shared.fetchGameBackground(game: randomGame) { [weak self] (image) in
            self?.backgroundImageView.image = image
        }
    }
    
    private func fetchUser() {
        if currentUser {
            username = Auth.auth().currentUser?.displayName
        }
        
        guard let username = username else { return }
        
        activityIndicator.startAnimating()
        UserController.fetchUser(username: username) { [weak self] (user) in
            self?.user = user
            self?.reloadData()
                        
            self?.fetchBackgroundImage()
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    deinit {
        print("\n\nProfileViewController Deinit\n\n")
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.games.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GameCell
        
        if let games = user?.games {
            cell.game = games[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width - 20
        let height = width * (9/16) - 30

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! ProfileHeader
        
        header.user = user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let user = user {
            let bannerHeight = view.frame.width * 0.4
            let profilePicHeight: CGFloat = 65.0
            let bioLabelHeight = user.bio.height(forConstrainedWidth: view.frame.width - 30, font: .systemFont(ofSize: 17)) + 30
            return CGSize(width: view.frame.width, height: bannerHeight + profilePicHeight + bioLabelHeight)
        } else {
            return .zero
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateViewsByScrollPosition(scrollView: scrollView)
    }
    
    private func updateViewsByScrollPosition(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 2.5)
        var offsetForImage = scrollView.contentOffset.y / (view.frame.height / 10)
        
        if offsetForNavBar > 0.95 {
            offsetForNavBar = 0.95
        }
        
        if offsetForNavBar <= 0 {
            navigationItem.titleView = nil
            offsetForNavBar = 0
        } else {
            titleLabel.text = user?.username
            navigationItem.titleView = titleLabel
        }
        
        if offsetForImage < 0.2 {
            offsetForImage = 0.2
        }
        
        if user?.games.count ?? 0 > 3 {
            navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue().withAlphaComponent(offsetForNavBar)), for: .default)
            titleLabel.alpha = offsetForNavBar
        }
    
        backgroundImageView.alpha = 1 - offsetForImage
    }
    
}
