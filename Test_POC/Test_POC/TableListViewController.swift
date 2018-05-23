//
//  TableListViewController.swift
//  iOS Example
//
//  Created by Nikunj Agrawal on 22/05/18.
//  Copyright © 2018 swift. All rights reserved.
//

import UIKit

class TableListViewController: UIViewController {
    
    var tableListArray = [String]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lists"
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.tableHeaderView = UIView(frame: .zero)

    }
}

extension TableListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableListCell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell") as! ListViewCell
        tableListCell.listNameLabel.text = tableListArray[indexPath.row];
        let imageUrl = URL(string: "http://76.74.177.168:8080/selected/\(tableListArray[indexPath.row]).jpg")
        tableListCell.listImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "PlaceHolder"))
        return tableListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

class ListViewCell: UITableViewCell {
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var listNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
