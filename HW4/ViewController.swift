//
//  ViewController.swift
//  HW4
//
//  Created by Nikolai  on 12.05.2023.
//

import UIKit

struct UserModel: Hashable{
    var name = ""
    var fl = false
}

enum TblSection{
    case first
}

typealias UserDataSource = UITableViewDiffableDataSource<TblSection, UserModel>
typealias UserSnapshot = NSDiffableDataSourceSnapshot<TblSection, UserModel>

class ViewController: UIViewController {

    var arrData = [UserModel]()
    let tblView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    var dataSource: UserDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Task 4"
        view.addSubview(tblView)
        
        configureDatasource()
        arrData = getAllData()
        createSnapshot(users: arrData)
        
        self.tblView.delegate = self
        tblView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        updateLayout(with: self.view.frame.size)
        
        let shuffleButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(shuffleButtonPressed))
        navigationItem.rightBarButtonItem = shuffleButton
    }
    
    private func updateLayout(with size: CGSize) {
        self.tblView.frame = CGRect(origin: .zero, size: size)
    }
    
    func configureDatasource() {
        dataSource = UserDataSource(tableView: tblView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
            cell.textLabel?.text = user.name
            if user.fl == false {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
            return cell
        })
    }
    
    func getAllData() -> [UserModel]{
        var dataArray = [UserModel]()
        let testArray = Array(0...30).map {String($0)}
        
        for str in testArray {
            dataArray.append(UserModel(name: str, fl: false))
        }
        
        return dataArray
    }
    
    func createSnapshot(users: [UserModel]){
        var snapshot = UserSnapshot()
        snapshot.appendSections([.first])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func shuffleButtonPressed() {
        let snapshot = dataSource.snapshot()
        var array = snapshot.itemIdentifiers
        array.shuffle()
        createSnapshot(users: array)
    }
    
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        var snapshot = dataSource.snapshot()
        var user = dataSource.itemIdentifier(for: indexPath)!
        snapshot.deleteItems([user])
        
        if user.fl == false {
            user.fl = true
            snapshot.insertItems([user], beforeItem: snapshot.itemIdentifiers[0])
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            user.fl = false
            snapshot.insertItems([user], beforeItem: snapshot.itemIdentifiers[indexPath.row])
            dataSource.apply(snapshot, animatingDifferences: false)
        }
        
        snapshot.reloadItems([user])
    }
}


class TableViewCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
    }
}

