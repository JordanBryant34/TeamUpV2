//
//  TeammatesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TeammatesViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var requestsBarButtonItem: UIBarButtonItem = {
        let image = UIImage(named: "requestsIcon")?.resize(newSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(requestsButtonTapped), for: .touchUpInside)
        
        let requestsBarButton = UIBarButtonItem(customView: button)
        return requestsBarButton
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
    
    var teammates: [User] = []
    
    var cellId = "cellId"
    var headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(TeammateCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchTeammates()
        makeNavigationBarClear()
        setupViews()
    }
    
    private func setupViews() {
        navigationItem.rightBarButtonItem = requestsBarButtonItem
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(collectionView)
        
        collectionView.pinEdgesToView(view: view)
        
        requestsBarButtonItem.customView?.setHeightAndWidthConstants(height: 35, width: 35)
    }
    
    private func fetchTeammates() {
        guard let currentUser = Auth.auth().currentUser?.displayName else { return }
        
        Database.database().reference().child("users").child(currentUser).child("teammates").observe(.value) { [weak self] (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                self?.teammates = []
                self?.reloadData()
                return
            }
            
            let teammateNames = Array(dictionary.keys)
            
            UserController.fetchUsers(usernames: teammateNames) { [weak self] (teammates) in
                self?.teammates = teammates
                self?.reloadData()
            }
        }
    }
    
    @objc private func requestsButtonTapped() {
        navigationController?.pushViewController(RequestsViewController(), animated: true)
    }

    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension TeammatesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teammates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeammateCell
        
        cell.user = teammates[indexPath.item]
        
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
