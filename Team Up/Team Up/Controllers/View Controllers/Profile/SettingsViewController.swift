//
//  SettingsViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 1/14/21.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    private let settingsTitles = [
        ["Edit profile picture", "Edit biography", "Edit region", "Edit mic status", "Edit games"],
        ["Log out"]
    ]
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupViews()
    }
    
    private func setupViews() {
        title = "Settings"
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.teamUpDarkBlue()), for: .default)
        view.backgroundColor = .teamUpBlue()
    
        view.addSubview(tableView)
        
        tableView.pinEdgesToView(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .default)
    }
    
    private func promptUserForSignOut() {
        let promptUserVC = PromptUserViewController()
        promptUserVC.modalPresentationStyle = .overFullScreen
        promptUserVC.titleText = "Don't leave me"
        promptUserVC.subTitleText = "Are you sure you want to log out?"
        promptUserVC.acceptButtonTitle = "Log out"
        promptUserVC.cancelButtonTitle = "Cancel"
        promptUserVC.delegate = self
        present(promptUserVC, animated: false, completion: nil)
    }
    
    deinit {
        print("\n\nSettingsViewController Deinit\n\n")
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.teamUpBlue().withAlphaComponent(0.5)
        
        cell.selectedBackgroundView = selectedView
        
        cell.textLabel?.text = settingsTitles[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = indexPath.section == 1 ? .danger() : .white
        cell.backgroundColor = .teamUpDarkBlue()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .clear
            headerView.backgroundView?.backgroundColor = .clear
            headerView.textLabel?.textColor = .accent()
            headerView.textLabel?.font = .boldSystemFont(ofSize: 15)
            
            switch section {
            case 0:
                headerView.textLabel?.text = "Profile"
            case 1:
                headerView.textLabel?.text = "Account"
            default:
                headerView.textLabel?.text = ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UITableViewHeaderFooterView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell?.textLabel?.text {
        case "Edit region":
            UserController.editRegion(viewController: self)
        case "Edit mic status":
            UserController.editMicStatus(viewController: self)
        case "Edit games":
            let addGamesViewController = AddGamesViewController()
            addGamesViewController.isEditingSettings = true
            navigationController?.pushViewController(addGamesViewController, animated: true)
        case "Edit biography":
            let addBioViewController = AddBioViewController()
            addBioViewController.continueButton.setTitle("Save", for: .normal)
            addBioViewController.isEditingSettings = true
            navigationController?.pushViewController(addBioViewController, animated: true)
        case "Log out":
            promptUserForSignOut()
        case "Edit profile picture":
            let selectProfilePicVC = SelectProfilePicViewController()
            selectProfilePicVC.modalPresentationStyle = .overFullScreen
            present(selectProfilePicVC, animated: true, completion: nil)
        default:
            print("Settings cell has no text")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SettingsViewController: PromptUserViewControllerDelegate {
    
    func userAcceptedPrompt() {
        UserController.signOutUser(viewController: self)
    }
    
}
