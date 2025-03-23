//
//  RoutineListViewController.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 21/03/25.
//

import UIKit
import UserNotifications

class RoutineListViewController: UITableViewController {
    private let store = RoutineStore.shared
    private var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Exercise Routine"

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("RoutinesUpdated"), object: nil)
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refreshCardView()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func refreshCardView() {
        if let cardView = view.viewWithTag(100) as? RoutineCardView {
            let nextUpcomingRoutine = store.getNextUpcomingRoutine()
            cardView.configure(with: nextUpcomingRoutine)
        }
    }
    
    @objc private func reloadData() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.routines.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell", for: indexPath) as! RoutineTableViewCell
        
        let routine = store.routines[indexPath.row]
        cell.configure(with: routine)
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        refreshCardView()
        
        // Update the card view with the next upcoming routine
        if let cardView = view.viewWithTag(100) as? RoutineCardView {
            let nextUpcomingRoutine = store.getNextUpcomingRoutine()
            cardView.configure(with: nextUpcomingRoutine)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let routine = store.routines[indexPath.row]
            store.routines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

            removeNotifications(for: routine)
        }
    }
    
    private func removeNotifications(for routine: Routine) {
        let center = UNUserNotificationCenter.current()
        
        for weekday in routine.weekdays {
            let identifier = "stretchReminder_\(routine.exerciseName)_\(weekday.rawValue)"
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
            print("Notification removed for \(routine.exerciseName) on \(weekday.shortName)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "EditRoutineSegue", sender: indexPath)
    }
    
    @IBAction func addRoutineButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "AddRoutineSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditRoutineSegue",
           let indexPath = sender as? IndexPath,
           let destVC = segue.destination as? AddRoutineViewController {
            
            destVC.routine = store.routines[indexPath.row]
            destVC.editIndex = indexPath.row
        }
    }
}
