//
//  RequestsViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/29/20.
//

import UIKit
import NVActivityIndicatorView

class RequestsViewController: UIViewController {
    
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
        label.text = "Teammate Requests"
        return label
    }()
    
    lazy var noDataView: NoDataView = {
        let view = NoDataView()
        let image = UIImage(named: "teamUpLogoTemplate")?.resize(newSize: CGSize(width: view.frame.width * 0.5, height: view.frame.width * 0.5)).withRenderingMode(.alwaysTemplate)
        view.imageView.image = image
        view.imageView.tintColor = .teamUpDarkBlue()
        view.textLabel.text = "You have no requests"
        view.detailTextLabel.text = "Find some players and request them, or check back here later."
        view.button.isHidden = true
        view.isHidden = true
        return view
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    let requestController = RequestController.shared
    
    var cellId = "cellId"
    var headerId = "headerId"
    
    var isAcceptingRequest = false
    var isDecliningRequest = false
    
    var requestingUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(TeammateRequestCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(requestController.teammateRequestNotification), object: nil)
        
        makeNavigationBarClear()
        setupViews()

        noDataView.isHidden = !requestController.teammateRequests.isEmpty
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeNavigationBarClear()
        updateNavigationBarByScrollPosition(scrollView: collectionView)
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(noDataView)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        noDataView.pinEdgesToView(view: view)
        collectionView.pinEdgesToView(view: view)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.noDataView.isHidden = !self.requestController.teammateRequests.isEmpty
            self.activityIndicator.stopAnimating()
        }
    }
    
    deinit {
        print("\n\nRequestsViewController Deinit\n\n")
    }
    
}

extension RequestsViewController: TeammateRequestCellDelegate {
    
    func acceptRequest(requestingUser: User, cell: TeammateRequestCell) {
        let promptUserVC = PromptUserViewController()
        promptUserVC.modalPresentationStyle = .overFullScreen
        promptUserVC.titleText = "Accept \(requestingUser.username)'s teammate request?"
        promptUserVC.subTitleText = "You can always remove them from your teammates list later."
        promptUserVC.acceptButtonTitle = "Accept Request"
        promptUserVC.cancelButtonTitle = "Cancel"
        promptUserVC.delegate = self
        
        isAcceptingRequest = true
        isDecliningRequest = false
        self.requestingUser = requestingUser
        
        present(promptUserVC, animated: false, completion: nil)
    }
    
    func declineRequest(requestingUser: User, cell: TeammateRequestCell) {
        let promptUserVC = PromptUserViewController()
        promptUserVC.modalPresentationStyle = .overFullScreen
        promptUserVC.titleText = "Decline \(requestingUser.username)'s teammate request?"
        promptUserVC.subTitleText = "You can always send them a teammate request later."
        promptUserVC.acceptButtonTitle = "Decline Request"
        promptUserVC.cancelButtonTitle = "Cancel"
        promptUserVC.isWarning = true
        promptUserVC.delegate = self
        
        isAcceptingRequest = false
        isDecliningRequest = true
        self.requestingUser = requestingUser
        
        present(promptUserVC, animated: false, completion: nil)
    }
}

extension RequestsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestController.teammateRequests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeammateRequestCell
        let user = requestController.teammateRequests[indexPath.item]
        
        cell.user = user
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! LargeTitleHeader
        
        header.titleLabel.text = "Requests"
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = requestController.teammateRequests[indexPath.item]
        
        let profileViewController = ProfileViewController()
        profileViewController.username = user.username
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBarByScrollPosition(scrollView: scrollView)
    }
    
    private func updateNavigationBarByScrollPosition(scrollView: UIScrollView) {
        var offsetForNavBar = scrollView.contentOffset.y / (view.frame.height / 2)
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

extension RequestsViewController: PromptUserViewControllerDelegate {
    
    func userAcceptedPrompt() {
        guard let requestingUser = requestingUser else { return }
        
        if isAcceptingRequest {
            requestController.acceptTeammateRequest(requestingUser: requestingUser)
        } else if isDecliningRequest {
            requestController.declineTeammateRequest(requestingUser: requestingUser)
        }
    }
    
    func promptDismissed() {
        isAcceptingRequest = false
        isDecliningRequest = false
        
        requestingUser = nil
    }
    
}
