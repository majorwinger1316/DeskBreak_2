//
//  dailyLeaderboardTableViewController.swift
//  DeskBreak_Test
//
//  Created by admin33 on 03/10/24.
//

import UIKit

class dailyLeaderboardTableViewController: UITableViewController {
    
    var peoples: [People] = [
        People(name: "Akshat Dutt Kaushik", description: "1", points: "3020", picture: "7"),
        People(name: "Swati Swapna", description: "2", points: "2080", picture: "7"),
        People(name: "Vansh Bhatia", description: "3", points: "2680", picture: "7"),
        People(name: "Ravi Kumar", description: "4", points: "2500", picture: "7"),
        People(name: "Neha Sharma", description: "5", points: "2200", picture: "7"),
        People(name: "Priya Rajan", description: "6", points: "2000", picture: "7"),
        People(name: "Ankit Mehta", description: "7", points: "1500", picture: "7"),
    ]
    
    override func loadView() {
        self.view = UITableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peoples.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath)

//        print(indexPath)
        let people = peoples[indexPath.row]
        
//        cell.textLabel?.text = "\(food.name)"
//        cell.detailTextLabel?.text = "\(food.description)"
        
        var content = cell.defaultContentConfiguration()
        
        content.text = people.name
        content.secondaryText = people.description
//        content.image = UIImage(named: "Cauliflower-Shawarma_8-500x500")
        
        cell.contentConfiguration = content
        cell.showsReorderControl = true
        
        cell.accessoryType = .detailButton

        return cell
    }

}
