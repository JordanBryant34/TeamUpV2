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
        label.text = "Teammates"
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
    
    var requestingUsers: [User] = []
    
    var cellId = "cellId"
    var headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(TeammateRequestCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    
        makeNavigationBarClear()
        setupViews()
        fetchRequests()
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
    
    private func fetchRequests() {
        activityIndicator.startAnimating()
        LFGController.fetchTeammateRequests { [weak self] (users) in
            self?.requestingUsers = users
            self?.reloadData()
        }
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.noDataView.isHidden = !self.requestingUsers.isEmpty
            self.activityIndicator.stopAnimating()
        }
    }
    
    deinit {
        print("\n\nRequestsViewController Deinit\n\n")
    }
    
}

extension RequestsViewController: TeammateRequestCellDelegate {
    func acceptRequest(requestingUser: User, cell: TeammateRequestCell) {
        let alertController = UIAlertController(title: "Add \(requestingUser.username) as a teammate?", message: nil, preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Add", style: .default) { [weak self] (_) in
            LFGController.acceptTeammateRequest(requestingUser: requestingUser)
            
            if let indexPath = self?.collectionView.indexPath(for: cell) {
                self?.requestingUsers.remove(at: indexPath.item)
                self?.collectionView.deleteItems(at: [indexPath])
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(acceptAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func declineRequest(requestingUser: User, cell: TeammateRequestCell) {
        let alertController = UIAlertController(title: "Decline \(requestingUser.username)'s teammate request?", message: nil, preferredStyle: .alert)
        
        let declineAction = UIAlertAction(title: "Decline", style: .default) { [weak self] (_) in
            LFGController.declineTeammateRequest(requestingUser: requestingUser)
            
            if let indexPath = self?.collectionView.indexPath(for: cell) {
                self?.requestingUsers.remove(at: indexPath.item)
                self?.collectionView.deleteItems(at: [indexPath])
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(declineAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension RequestsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return requestingUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeammateRequestCell
        let user = requestingUsers[indexPath.item]
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
