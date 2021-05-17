//
//  SelectGameViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 5/2/21.
//

import UIKit
import FirebaseAuth
import NVActivityIndicatorView
import MoPubSDK

protocol SelectGameViewControllerDelegate: AnyObject {
    func gameSelected(game: Game)
}

class SelectGameViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cancelIcon")?.resize(newSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let gameController = GameController.shared
    private var games: [Game] = []
    private var cellId = "cellId"
    private var headerId = "headerId"
    private var promptAccepted = false
    
    var selectedGame: Game?
    var showAllGames = false
    var requiresConfirmation = false
    var userPrompt: UserActionPrompt?
    var headerLabelText = ""
    var delegate: SelectGameViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GameCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        exitButton.addTarget(self, action: #selector(exitPressed), for: .touchUpInside)
        
        fetchGames()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AdController.shared.adController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AdController.shared.adController?.delegate = nil
    }
    
    private func fetchGames() {
        if showAllGames {
            if !gameController.games.isEmpty {
                games = gameController.games
            } else {
                activityIndicator.startAnimating()
                gameController.fetchAllGames { [weak self] (games) in
                    self?.games = games
                    self?.reloadData()
                }
            }
        } else {
            guard let currentUser = Auth.auth().currentUser?.displayName else { return }
            activityIndicator.startAnimating()
            UserController.fetchUsersGames(username: currentUser) { [weak self] (games) in
                self?.games = games
                self?.reloadData()
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(collectionView)
        view.addSubview(exitButton)
        view.addSubview(activityIndicator)
        
        exitButton.setHeightAndWidthConstants(height: 30, width: 30)
        exitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        
        collectionView.pinEdgesToView(view: view)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    private func getConfirmationTitle() -> String {
        switch userPrompt {
            case .goOnlineForGame:
                return "Appear online for \(selectedGame?.name ?? "")?"
            default:
                return ""
        }
    }
    
    private func getConfirmationSubtitle() -> String {
        switch userPrompt {
            case .goOnlineForGame:
                return "Appearing online will mark you as \"Playing Now\" and allow other users to find you easier."
            default:
                return ""
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
    }
    
    @objc private func exitPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("\n\nSelectGamesViewController Deinit\n\n")
    }
    
}

extension SelectGameViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GameCell
        
        cell.game = games[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: (view.frame.width - 20) * (9/16) - 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! LargeTitleHeader
        
        header.titleLabel.text = headerLabelText
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if requiresConfirmation {
            selectedGame = games[indexPath.item]
            let promptVC = PromptUserViewController()
            promptVC.modalPresentationStyle = .overFullScreen
            promptVC.acceptButtonTitle = "Confirm"
            promptVC.cancelButtonTitle = "Cancel"
            promptVC.titleText = getConfirmationTitle()
            promptVC.subTitleText = getConfirmationSubtitle()
            promptVC.delegate = self
            present(promptVC, animated: false, completion: nil)
        } else {
            let game = games[indexPath.item]
            delegate?.gameSelected(game: game)
        }
        
    }
    
}

extension SelectGameViewController: PromptUserViewControllerDelegate {
    
    func userAcceptedPrompt() {
        guard let game = selectedGame else { return }
        promptAccepted = true
        delegate?.gameSelected(game: game)
    }
    
    func promptDismissed() {
        if promptAccepted {
            if let adController = AdController.shared.adController, adController.ready, userPrompt == .goOnlineForGame {
                adController.show(from: self)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension SelectGameViewController: MPInterstitialAdControllerDelegate {
    
    func interstitialDidDismiss(_ interstitial: MPInterstitialAdController!) {
        AdController.shared.adController?.loadAd()
        if let parent = presentingViewController {
            dismiss(animated: true) {
                SubscriptionController.shared.presentSubscriptionController(viewController: parent)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
