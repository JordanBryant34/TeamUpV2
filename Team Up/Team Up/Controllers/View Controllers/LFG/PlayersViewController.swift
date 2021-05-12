//
//  PlayersViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/26/20.
//

import UIKit
import NVActivityIndicatorView

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
    
    lazy var noDataView: NoDataView = {
        let view = NoDataView()
        let image = UIImage(named: "teamUpLogoTemplate")?.resize(newSize: CGSize(width: view.frame.width * 0.5, height: view.frame.width * 0.5)).withRenderingMode(.alwaysTemplate)
        view.imageView.image = image
        view.imageView.tintColor = .teamUpDarkBlue()
        view.textLabel.text = "No players found"
        view.detailTextLabel.text = "Broaden your filters or try again later."
        view.button.isHidden = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    
    var game: Game?
    let cellId = "cellId"
    let headerId = "headerId"
    
    var users: [User] = []
    var requestedUsers: [User] = []
    
    private var alreadyPromptedForNotifications = false
    private var actionPrompt: UserActionPrompt?
    
    let gameController = GameController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.register(PlayerCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
            
        setupViews()
        fetchPlayers(platform: nil, region: nil)
        makeNavigationBarClear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeNavigationBarClear()
        updateViewsByScrollPosition(scrollView: collectionView)
    }
    
    private func setupViews() {
        navigationItem.titleView = titleLabel
        navigationItem.rightBarButtonItem = filtersBarButtonItem
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(noDataView)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: (10/16)).isActive = true
        
        filtersBarButtonItem.customView?.setHeightAndWidthConstants(height: 35, width: 35)
            
        noDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.height * 0.1).isActive = true
        noDataView.setHeightAndWidthConstants(height: view.frame.height, width: view.frame.width)
        
        collectionView.pinEdgesToView(view: view)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
        
        if let game = game {
            titleLabel.text = game.name
            gameController.fetchGameBackground(game: game) { [weak self] (image) in
                self?.backgroundImageView.image = image
            }
        }
    }
    
    private func fetchPlayers(platform: String?, region: Region?) {
        guard let game = game else { return }
    
        activityIndicator.startAnimating()
        
        LFGController.fetchPlayers(game: game, platform: platform, region: region) { [weak self] (users, onlineUsers) in
            self?.users = onlineUsers + users
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
            self.noDataView.isHidden = !self.users.isEmpty
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func reloadCells(indexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: indexPath)
            self.noDataView.isHidden = !self.users.isEmpty
        }
    }
    
    private func promptForNotifications(requestedUser: String) {
        let notificationsPromptVC = PromptUserViewController()
        notificationsPromptVC.modalPresentationStyle = .overFullScreen
        notificationsPromptVC.titleText = "Want to know when \(requestedUser) accepts your teammate request?"
        notificationsPromptVC.subTitleText = "Enable notifications to be alerted when other players interact with you."
        notificationsPromptVC.acceptButtonTitle = "Enable Notifications"
        notificationsPromptVC.cancelButtonTitle = "No thanks"
        notificationsPromptVC.delegate = self
        
        actionPrompt = .notifications
        
        present(notificationsPromptVC, animated: false, completion: nil)
        alreadyPromptedForNotifications = true
    }
    
    private func promptForAd() {
        let adPromptVC = PromptUserViewController()
        adPromptVC.modalPresentationStyle = .overFullScreen
        adPromptVC.titleText = "We know this isn't ideal."
        adPromptVC.subTitleText = "In order to keep the app available to everyone, Team Up is largely supported by ads.\n\nView this ad to be able to send more teammate requests."
        adPromptVC.cancelButtonTitle = "No thanks"
        adPromptVC.timerLength = 3
        adPromptVC.acceptButtonTitle = "Ad will play in \(Int(adPromptVC.timerLength))..."
        adPromptVC.acceptButtonEnabled = false
        adPromptVC.delegate = self
        
        actionPrompt = .ad
        
        present(adPromptVC, animated: false, completion: nil)
        alreadyPromptedForNotifications = true
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
        cell.game = game
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        
        let profileVC = ProfileViewController()
        profileVC.username = user.username
        
        navigationController?.pushViewController(profileVC, animated: true)
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
//        if AdController.shared.requestsCount >= 3 && AdController.shared.rewardedInterstitialAd != nil {
//            promptForAd()
//            return
//        }
        
        RequestController.shared.requestPlayerToTeamUp(username: user.username) { [weak self] (success) in
            if success {
                self?.requestedUsers.append(user)
                cell.alreadyRequested = true
                
                if !NotificationsController.isRegisteredForNotifications && self?.alreadyPromptedForNotifications == false {
                    self?.promptForNotifications(requestedUser: user.username)
                }
            }
        }
    }
    
}

extension PlayersViewController: PromptUserViewControllerDelegate {
    
    func userAcceptedPrompt() {
        if actionPrompt == .notifications {
            NotificationsController.userWantsNotifications()
        }
    }
    
    func timerUpdated(currentTime: TimeInterval, promptVC: PromptUserViewController) {
        if actionPrompt == .ad {
            promptVC.acceptButtonTitle = "Ad will play in \(Int(currentTime))..."
        }
    }
    
    func timerEnded() {
//        if AdController.shared.rewardedInterstitialAd != nil {
//            if actionPrompt == .ad {
//                AdController.shared.rewardedInterstitialAd?.fullScreenContentDelegate = self
//                AdController.shared.showRequestsRewardAd()
//            }
//        } else {
//            AdController.shared.loadRewardedInterstitialAd()
//        }
        
        actionPrompt = nil
    }
    
}
