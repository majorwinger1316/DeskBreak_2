//
//  dataModel.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import Foundation
import FirebaseFirestore

struct UserRegistrationData {
    var username: String = ""
    var dateOfBirth: Date? = nil
    var email: String = ""
    var contactNumber: String = ""
    var password: String = ""
    var dailyTarget: Int16 = 0
}

class User {
    var userId: String
    var username: String
    var email: String
    var passwordHash: String?  // Make passwordHash optional
    var profilePicture: String?  // Optional profile picture URL (Firebase storage URL)
    var dailyTarget: Int16
    var totalMinutes: Int32
    var totalPoints: Int32
    var createdAt: Date
    var dateOfBirth: Date  // Ensure this is stored as Date
    var contactNumber: String
    var dailyMinutes: Int32
    var dailyPoints: Int32
    var lastActivityDate: Date

    init?(data: [String: Any]) {
        // Basic fields parsing
        guard let userId = data["userId"] as? String,
              let username = data["username"] as? String,
              let email = data["email"] as? String,
              let dailyTarget = data["dailyTarget"] as? Int16,
              let totalMinutes = data["totalMinutes"] as? Int32,
              let totalPoints = data["totalPoints"] as? Int32,
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let contactNumber = data["contactNumber"] as? String,
              let dailyMinutes = data["dailyMinutes"] as? Int32,
              let dailyPoints = data["dailyPoints"] as? Int32,
              let lastActivityTimestamp = data["lastActivityDate"] as? Timestamp else {
            print("Failed to parse required fields: \(data)")
            return nil
        }

        // Convert Firestore Timestamps to Date
        let createdAt = createdAtTimestamp.dateValue()
        let lastActivityDate = lastActivityTimestamp.dateValue()

        // Parse `dateOfBirth` as a Timestamp (converted to Date)
        var dateOfBirth: Date?
        if let dateOfBirthTimestamp = data["dateOfBirth"] as? Timestamp {
            dateOfBirth = dateOfBirthTimestamp.dateValue()  // Convert Timestamp to Date
        } else {
            print("No dateOfBirth field found or invalid format.")
            return nil
        }

        // Handle the optional `passwordHash` field
        let passwordHash = data["passwordHash"] as? String  // Optional field

        // Initialize properties with safe values
        self.userId = userId
        self.username = username
        self.email = email
        self.passwordHash = passwordHash  // Can be nil if not present
        self.profilePicture = data["profilePicture"] as? String  // This is the Firebase URL (Optional)
        self.dailyTarget = dailyTarget
        self.totalMinutes = totalMinutes
        self.totalPoints = totalPoints
        self.createdAt = createdAt
        self.dateOfBirth = dateOfBirth ?? Date()  // Default to current date if parsing fails
        self.contactNumber = contactNumber
        self.dailyMinutes = dailyMinutes
        self.dailyPoints = dailyPoints
        self.lastActivityDate = lastActivityDate
    }

    // Full Initializer for Firestore creation
    init(userId: String, username: String, email: String, passwordHash: String?, profilePicture: String?, dailyTarget: Int16, totalMinutes: Int32, totalPoints: Int32, createdAt: Date, dateOfBirth: Date, contactNumber: String, dailyMinutes: Int32, dailyPoints: Int32, lastActivityDate: Date) {
        self.userId = userId
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.profilePicture = profilePicture
        self.dailyTarget = dailyTarget
        self.totalMinutes = totalMinutes
        self.totalPoints = totalPoints
        self.createdAt = createdAt
        self.dateOfBirth = dateOfBirth
        self.contactNumber = contactNumber
        self.dailyMinutes = dailyMinutes
        self.dailyPoints = dailyPoints
        self.lastActivityDate = lastActivityDate
    }

    // Utility function to parse Firestore data and convert to User object
    static func fromFirestoreData(_ data: [String: Any]) -> User? {
        return User(data: data)
    }
}

struct Game {
    let name: String
    let description: String
    let points: String
    let photo: String
    let time: String
}

// GameSession class for user sessions
class GameSession {
    var sessionId: String
    var startTime: Date
    var endTime: Date
    var minutesPlayed: Int16
    var pointsEarned: Int16
    var userId: String

    init(sessionId: String, startTime: Date, endTime: Date, minutesPlayed: Int16, pointsEarned: Int16, userId: String) {
        self.sessionId = sessionId
        self.startTime = startTime
        self.endTime = endTime
        self.minutesPlayed = minutesPlayed
        self.pointsEarned = pointsEarned
        self.userId = userId
    }

    // Convenience initializer to convert Firestore document to GameSession model
    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let sessionId = data["sessionId"] as? String,
              let startTimeTimestamp = data["startTime"] as? Timestamp,
              let endTimeTimestamp = data["endTime"] as? Timestamp,
              let minutesPlayed = data["minutesPlayed"] as? Int16,
              let pointsEarned = data["pointsEarned"] as? Int16,
              let userId = data["userId"] as? String else {
            return nil
        }
        
        self.init(sessionId: sessionId,
                  startTime: startTimeTimestamp.dateValue(),
                  endTime: endTimeTimestamp.dateValue(),
                  minutesPlayed: minutesPlayed,
                  pointsEarned: pointsEarned,
                  userId: userId)
    }
}

// Community and CommunityMembership models can be similarly adjusted to match Firestore documents
// Community class for representing a community
class Community {
    var communityId: String
    var communityName: String
    var descriptionText: String
    var communityCode: String
    var latitude: Double
    var longitude: Double
    var createdBy: String
    var createdAt: Date
    var members: [String] = []

    init(communityId: String, communityName: String, descriptionText: String, communityCode: String, latitude: Double, longitude: Double, createdBy: String, createdAt: Date) {
        self.communityId = communityId
        self.communityName = communityName
        self.descriptionText = descriptionText
        self.communityCode = communityCode
        self.latitude = latitude
        self.longitude = longitude
        self.createdBy = createdBy
        self.createdAt = createdAt
    }

    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
            print("No data found for document: \(document.documentID)")
            return nil
        }

        print("Document Data: \(data)")

        // Ensure that communityCode is extracted from Firestore
        guard let communityId = data["communityId"] as? String,
              let communityName = data["communityName"] as? String,
              let communityCode = data["communityCode"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double,
              let createdBy = data["createdBy"] as? String,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            print("Missing required fields or wrong data types in document \(document.documentID)")
            return nil
        }

        let descriptionText = data["descriptionText"] as? String ?? ""

        self.init(communityId: communityId,
                  communityName: communityName,
                  descriptionText: descriptionText,
                  communityCode: communityCode,
                  latitude : latitude,
                  longitude: longitude,
                  createdBy: createdBy,
                  createdAt: createdAtTimestamp.dateValue())
    }

//    // MARK: - Add or Remove Member Methods
//    func addMember(user: User) {
//        if !members.contains(where: { $0.userId == user.userId }) {
//            members.append(user)
//            // Optionally, you can save this change to Firestore here
//            print("Member \(user.username) added to community \(communityName).")
//        }
//    }
//
//    func removeMember(user: User) {
//        if let index = members.firstIndex(where: { $0.userId == user.userId }) {
//            members.remove(at: index)
//            // Optionally, you can save this change to Firestore here
//            print("Member \(user.username) removed from community \(communityName).")
//        }
//    }

    // MARK: - Fetch Community Members from Firestore
    func fetchMembersFromFirestore(completion: @escaping ([User]) -> Void) {
        let db = Firestore.firestore()
        db.collection("communities")
            .document(communityId)
            .collection("members")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching members: \(error)")
                    completion([])
                    return
                }

                var fetchedMembers: [User] = []
                for document in snapshot?.documents ?? [] {
                    if let userData = document.data() as? [String: Any] {
                        if let user = User.fromFirestoreData(userData) {
                            fetchedMembers.append(user)
                        }
                    }
                }
                completion(fetchedMembers)
            }
    }
}


// CommunityMembership class for representing a user's membership in a community
class CommunityMembership {
    var membershipId: String
    var userId: String
    var communityId: String
    var joinedAt: Date

    init(membershipId: String, userId: String, communityId: String, joinedAt: Date) {
        self.membershipId = membershipId
        self.userId = userId
        self.communityId = communityId
        self.joinedAt = joinedAt
    }

    convenience init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

        guard let membershipId = data["membershipId"] as? String,
              let userId = data["userId"] as? String,
              let communityId = data["communityId"] as? String,
              let joinedAtTimestamp = data["joinedAt"] as? Timestamp else {
            return nil
        }

        self.init(membershipId: membershipId,
                  userId: userId,
                  communityId: communityId,
                  joinedAt: joinedAtTimestamp.dateValue())
    }

    // MARK: - Add Membership to Firestore
    func saveMembershipToFirestore() {
        let db = Firestore.firestore()
        let membershipData: [String: Any] = [
            "membershipId": membershipId,
            "userId": userId,
            "communityId": communityId,
            "joinedAt": Timestamp(date: joinedAt)
        ]
        
        db.collection("communities")
            .document(communityId)
            .collection("members")
            .document(membershipId)
            .setData(membershipData) { error in
                if let error = error {
                    print("Error adding membership: \(error)")
                } else {
                    print("Membership successfully added to Firestore.")
                }
            }
    }
}

enum Sequence: CaseIterable {
    case leftArmUp, rightArmUp, bothArms45, bothArmsUp, bothArmsDown
    
    var displayName: String {
        switch self {
        case .leftArmUp: return "Raise left Arm Up"
        case .rightArmUp: return "Raise right Arm Up"
        case .bothArms45: return "Raise both arms at 45°"
        case .bothArmsUp: return "Both Arms Up"
        case .bothArmsDown: return "Bring both arms down"
        }
    }
    
    var iconName: String {
        switch self {
        case .leftArmUp: return "hand.point.left.fill"
        case .rightArmUp: return "hand.point.right.fill"
        case .bothArms45: return "arrow.up.forward"
        case .bothArmsUp: return "arrow.up"
        case .bothArmsDown: return "arrow.down"
        }
    }
    
    var instructions: String {
        switch self {
        case .leftArmUp: return "Raise your LEFT arm straight up!"
        case .rightArmUp: return "Raise your RIGHT arm straight up!"
        case .bothArms45: return "Hold both arms at 45 degree angle"
        case .bothArmsUp: return "Raise BOTH arms straight up!"
        case .bothArmsDown: return "Lower both arms down slowly"
        }
    }
}
