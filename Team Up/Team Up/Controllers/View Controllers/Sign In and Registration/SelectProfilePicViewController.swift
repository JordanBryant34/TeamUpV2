//
//  SelectProfilePicViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/30/21.
//

import UIKit
import NVActivityIndicatorView

protocol SelectProfilePicViewControllerDelegate: AnyObject {
    func profilePicChosen(imageUrl: String)
}

class SelectProfilePicViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
        return collectionView
    }()
    
    let selectPicLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a profile picture"
        label.font = .boldSystemFont(ofSize: 17.5)
        label.textAlignment = .center
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "xIcon")?.resize(newSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysTemplate)
        button.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var delegate: SelectProfilePicViewControllerDelegate?
    
    private let cellId = "cellId"
    private let headerId = "headerId"
    
    private var imageUrlsDictionary: [String : [String]] = [:]
    private var categories: [String] = []
    
    var selectedImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ProfilePicCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(SectionTitleHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        setupViews()
        fetchPics()
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        view.addSubview(selectPicLabel)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
                
        doneButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 10, widthConstant: 70, heightConstant: 30)
        
        cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        cancelButton.setHeightAndWidthConstants(height: 30, width: 30)
        
        selectPicLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectPicLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        
        collectionView.anchor(selectPicLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        activityIndicator.centerInView(view: view)
        activityIndicator.setHeightAndWidthConstants(height: view.frame.width * 0.15, width: view.frame.width * 0.15)
    }
    
    private func fetchPics() {
        imageUrlsDictionary = [:]
        categories = []
        
        activityIndicator.startAnimating()
        
        UserController.fetchAllProfilePictures { [weak self] (imageUrlsDictionary) in
            self?.imageUrlsDictionary = imageUrlsDictionary
            self?.categories = imageUrlsDictionary.keys.sorted()
            
            if let indexOfTeamUp = self?.categories.firstIndex(of: "Team Up") {
                self?.categories.remove(at: indexOfTeamUp)
                self?.categories.insert("Team Up", at: 0)
            }
            
            self?.reloadData()
        }
    }
    
    @objc private func doneButtonTapped() {
        if let imageUrl = selectedImageUrl {
            UserController.setProfilePicture(imageUrl: imageUrl)
            delegate?.profilePicChosen(imageUrl: imageUrl)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
            
            UIView.animate(withDuration: 0.3) {
                self.collectionView.alpha = 1.0
            }
        }
    }
    
    deinit {
        print("\n\nSelectProfilePicViewController Deinit\n\n")
    }
    
}

extension SelectProfilePicViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfilePicCell
        
        let category = categories[indexPath.section]
        if let urlsArray = imageUrlsDictionary[category] {
            let imageUrl = urlsArray[indexPath.row]
            UserController.fetchProfilePicture(picUrl: imageUrl) { (image) in
                cell.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! SectionTitleHeader
            
            header.label.text = categories[indexPath.section]
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = categories[section]
        
        return (imageUrlsDictionary[category] ?? []).count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.frame.width - 60) / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.section]
        if let urlsArray = imageUrlsDictionary[category] {
            let imageUrl = urlsArray[indexPath.row]
            
            selectedImageUrl = imageUrl
        }
    }
    
}
