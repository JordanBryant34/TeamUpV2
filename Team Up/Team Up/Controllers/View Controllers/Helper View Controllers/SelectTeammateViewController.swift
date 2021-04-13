//
//  SelectTeammateViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/7/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import NVActivityIndicatorView

protocol SelectTeammatesViewControllerDelegate: AnyObject {
    func createChat(user: User)
}

extension SelectTeammatesViewControllerDelegate {
    func createChat(user: User) { /* empty default implementation */ }
}

class SelectTeammateViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var noDataView: NoDataView = {
        let view = NoDataView()
        let image = UIImage(named: "teamUpLogoTemplate")?.resize(newSize: CGSize(width: view.frame.width * 0.5, height: view.frame.width * 0.5)).withRenderingMode(.alwaysTemplate)
        view.imageView.image = image
        view.imageView.tintColor = .teamUpDarkBlue()
        view.textLabel.text = "You have no teammtes"
        view.detailTextLabel.text = "Find some players and request them to team up!"
        view.button.isHidden = true
        view.isHidden = true
        return view
    }()
    
    let exitButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "cancelIcon")?.resize(newSize: CGSize(width: 25, height: 25))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let teammateController = TeammateController.shared
    var delegate: SelectTeammatesViewControllerDelegate?
    
    var cellId = "cellId"
    var headerId = "headerId"
    
    var headerLabelText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(TeammateCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LargeTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        exitButton.addTarget(self, action: #selector(exitPressed), for: .touchUpInside)
        
        makeNavigationBarClear()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(noDataView)
        view.addSubview(exitButton)
        view.addSubview(collectionView)
        
        exitButton.setHeightAndWidthConstants(height: 30, width: 30)
        exitButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        
        noDataView.pinEdgesToView(view: view)
        
        collectionView.anchor(exitButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        if teammateController.teammates.isEmpty {
            noDataView.isHidden = false
        }
    }
    
    @objc private func exitPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("\n\nSelectTeammatesViewController Deinit\n\n")
    }

}

extension SelectTeammateViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teammateController.teammates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! TeammateCell
        
        cell.user = teammateController.teammates[indexPath.item]
        
        cell.messageButton.isHidden = true
        cell.moreButton.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! LargeTitleHeader
        
        header.titleLabel.text = headerLabelText
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = teammateController.teammates[indexPath.item]
        
        delegate?.createChat(user: user)
        
        self.dismiss(animated: true, completion: nil)
    }

}

