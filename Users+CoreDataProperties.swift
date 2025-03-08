//
//  Users+CoreDataProperties.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 01/03/25.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var contactNumber: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var dailyMinutes: Int32
    @NSManaged public var dailyPoints: Int32
    @NSManaged public var dailyTarget: Int16
    @NSManaged public var dateOfBirth: Date?
    @NSManaged public var email: String?
    @NSManaged public var lastActivityDate: Date?
    @NSManaged public var profilePicture: String?
    @NSManaged public var totalMinutes: Int32
    @NSManaged public var totalPoints: Int32
    @NSManaged public var userId: String?
    @NSManaged public var username: String?

}

extension Users : Identifiable {

}
