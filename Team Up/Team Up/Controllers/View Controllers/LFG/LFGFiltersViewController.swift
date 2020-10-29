//
//  LFGFiltersViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/28/20.
//

import UIKit

protocol LFGFiltersViewControllerDelegate: AnyObject {
    func filter(platform: String?, region: Region?)
}

class LFGFiltersViewController: UIViewController {
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.teamUpBlue().withAlphaComponent(0.975)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    let grabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .separatorColor()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = true
        return tableView
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
    
    var game: Game?
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var cellId = "cellId"
    
    var selectedRegion: Region?
    var selectedPlatform: String?
    
    weak var delegate: LFGFiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        setActionsAndGestures()
        setupViews()
    }
    
    private func setActionsAndGestures() {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
    }
    
    private func setupViews() {
        let statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 45
        
        view.addSubview(backgroundView)
        
        backgroundView.addSubview(grabBarView)
        backgroundView.addSubview(tableView)
        backgroundView.addSubview(doneButton)
        backgroundView.addSubview(cancelButton)
        
        backgroundView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: statusBarHeight + 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        grabBarView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10).isActive = true
        grabBarView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        grabBarView.setHeightAndWidthConstants(height: 5, width: 60)
        
        tableView.anchor(backgroundView.topAnchor, left: backgroundView.leftAnchor, bottom: backgroundView.bottomAnchor, right: backgroundView.rightAnchor, topConstant: 70, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        doneButton.anchor(backgroundView.topAnchor, left: nil, bottom: tableView.topAnchor, right: backgroundView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 90, heightConstant: 0)
        
        cancelButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 20).isActive = true
        cancelButton.setHeightAndWidthConstants(height: 30, width: 30)
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneButtonTapped() {
        delegate?.filter(platform: selectedPlatform, region: selectedRegion)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    deinit {
        print("\n\nLFGFiltersViewController Deinit\n\n")
    }
}

extension LFGFiltersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Region.allCases.count
        case 1:
            return game?.platforms.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)!
        
        cell.backgroundColor = .clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = .accent()
        
        cell.selectedBackgroundView = selectedView
        
        cell.textLabel?.textColor = .white
        
        if indexPath.section == 0 {
            cell.textLabel?.text = Region.allCases[indexPath.row].rawValue
        } else {
            if let game = game {
                cell.textLabel?.text = game.platforms[indexPath.row]
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for selectedIndexPath in selectedIndexPaths {
                if selectedIndexPath.section == indexPath.section {
                    tableView.deselectRow(at: selectedIndexPath, animated: false)
                }
            }
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedRegion = Region.allCases[indexPath.row]
        } else if indexPath.section == 1 {
            guard let game = game else { return }
            selectedPlatform = game.platforms[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedRegion = nil
        } else if indexPath.section == 1 {
            selectedPlatform = nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Filter by region"
        case 1:
            return "Filter by platform"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .accent()
        header.textLabel?.font = .boldSystemFont(ofSize: 22.5)
        header.textLabel?.frame = CGRect(x: 20, y: 0, width: view.frame.width, height: 25)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
