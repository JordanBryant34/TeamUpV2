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
        ["Logout"]
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
        
        cell.textLabel?.text = settingsTitles[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = indexPath.section == 1 ? .systemRed : .white
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
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "Profile"
//        default:
//            return ""
//        }
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
