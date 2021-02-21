//
//  TeammatesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import NVActivityIndicatorView

class TeammatesViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.alpha = 0
        label.textColor = .white
        label.text = "Teammates"
        return label
    }()
    
    private lazy var noDataView: NoDataView = {
        let view = NoDataView()
        let image = UIImage(named: "teamUpLogoTemplate")?.resize(newSize: CGSize(width: view.frame.width * 0.5, height: view.frame.width * 0.5)).withRenderingMode(.alwaysTemplate)
        view.imageView.image = image
        view.imageView.tintColor = .teamUpDarkBlue()
        view.textLabel.text = "You have no teammates"
        view.detailTextLabel.text = "Find some players and request them to team up!"
        view.button.setTitle("Find Teammates", for: .normal)
        view.isHidden = true
        return view
    }()
    
    private let teammateController = TeammateController.shared
    private let messageController = MessageController.shared
    
    private var cellId = "cellId"
    private var headerId = "headerId"
    
    private var teammateToRemove: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(TeammateCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        noDataView.button.addTarget(self, action: #selector(handleFindTeammates), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("teammatesUpdated"), object: nil)
        
        makeNavigationBarClear()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        makeNavigationBarClear()
        updateNavigationBarAppearance(scrollView: collectionView)
    }
    
    private func setupViews() {
        let requestsBarButtonItem = UIBarButtonItem(image: UIImage(named: "requestsIcon"), style: .plain, target: self, action: #selector(requestsButtonTapped))
        navigationItem.rightBarButtonItem = requestsBarButtonItem
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(collectionView)
        view.addSubview(noDataView)
        
        noDataView.pinEdgesToView(view: view)
        collectionView.pinEdgesToView(view: view)
        
        requestsBarButtonItem.customView?.setHeightAndWidthConstants(height: 35, width: 35)
        
        noDataView.isHidden = !teammateController.teammates.isEmpty
    }
    
    @objc private func requestsButtonTapped() {
        navigationController?.pushViewController(RequestsViewController(), animated: true)
    }
    
    @objc private func handleFindTeammates() {
        tabBarController?.selectedIndex = 0
        tabBarController?.selectedViewController = tabBarController?.viewControllers![0]
    }

    @objc private func reloadData() {
        DispatchQueue.main.async {
            self.noDataView.isHidden = !self.teammateController.teammates.isEmpty
            self.collectionView.reloadData()
        }
    }
}

extension TeammatesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teammateController.teammates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeammateCell
        
        cell.user = teammateController.teammates[indexPath.item]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! LargeTitleHeader
        
        header.titleLabel.text = "Teammates"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = teammateController.teammates[indexPath.item]
        
        let profileVC = ProfileViewController()
        profileVC.user = user
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarAppearance(scrollView: scrollView)
    }
    
    private func updateNavigationBarAppearance(scrollView: UIScrollView) {
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 10)
        var offsetForLabels = scrollView.contentOffset.y / (view.frame.height * 0.03)
        
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
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue().withAlphaComponent(offsetForNavBar)), for: .default)
        titleLabel.alpha = offsetForNavBar
        
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? LargeTitleHeader {
            header.titleLabel.alpha = 1 - offsetForLabels
        }
    }
    
}

extension TeammatesViewController: TeammateCellDelegate {
    
    func messageButtonTapped(cell: TeammateCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let teammate = teammateController.teammates[indexPath.item]
        
        let chatController = ChatViewController()
            
        if let chat = messageController.chats.first(where: {$0.chatPartner == teammate}) {
            chatController.chat = chat
            print("chat already exists")
        } else {
            chatController.chat = DirectChat(chatPartner: teammate, messages: [])
            print("chat does not already exist")
        }
            
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func moreButtonTapped(cell: TeammateCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let teammate = teammateController.teammates[indexPath.item]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let removeTeammateAction = UIAlertAction(title: "Remove teammate", style: .destructive) { [weak self] (_) in
            let promptUserVC = PromptUserViewController()
            promptUserVC.modalPresentationStyle = .overFullScreen
            promptUserVC.titleText = "Remove \(teammate.username) from your teammates list?"
            promptUserVC.subTitleText = "This will also remove you from their teammates list."
            promptUserVC.acceptButtonTitle = "Remove Teammate"
            promptUserVC.cancelButtonTitle = "Cancel"
            promptUserVC.isWarning = true
            
            if let strongSelf = self {
                strongSelf.teammateToRemove = teammate
                promptUserVC.delegate = strongSelf
                strongSelf.present(promptUserVC, animated: false, completion: nil)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(removeTeammateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension TeammatesViewController: PromptUserViewControllerDelegate {
    
    func userAcceptedPrompt() {
        guard let teammate = teammateToRemove else { return }
        teammateController.removeTeammate(teammate: teammate)
        
        teammateToRemove = nil
    }
    
}
