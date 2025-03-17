//
//  CoreDataManager.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 16/03/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "dataModelCoreData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data: \(error.localizedDescription)")
            }
        }
    }
    // MARK: - Fetch User Session
    func fetchUserSession() -> UserSession? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserSession> = UserSession.fetchRequest()

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching user session: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Save User Session
    func saveUserSession(userId: String, username: String, email: String, profilePicture: String?, dailyTarget: Int16, dailyMinutes: Int16) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserSession> = UserSession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userId == %@", userId)

        do {
            let existingUser = try context.fetch(fetchRequest).first ?? UserSession(context: context)
            existingUser.userId = userId
            existingUser.username = username
            existingUser.email = email
            existingUser.profilePicture = profilePicture
            existingUser.dailyTarget = Float(dailyTarget)
            existingUser.dailyMinutes = Float(dailyMinutes)

            saveContext()
        } catch {
            print("Error saving user session: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete User Session
    func deleteUserSession() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserSession> = UserSession.fetchRequest()

        do {
            let sessions = try context.fetch(fetchRequest)
            for session in sessions {
                context.delete(session)
            }
            saveContext()
        } catch {
            print("Error deleting user session: \(error.localizedDescription)")
        }
    }
}
