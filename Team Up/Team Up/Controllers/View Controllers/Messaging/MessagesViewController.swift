//
//  MessagesViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class MessagesViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNavigationBarClear()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: cellId)
        
        makeNavigationBarClear()
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        tableView.pinEdgesToView(view: view)
    }
    
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ChatTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = LargeTitleTableViewHeader()
        header.titleLabel.text = "Messages"
        header.backgroundColor = .teamUpBlue()
        header.tintColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
}
