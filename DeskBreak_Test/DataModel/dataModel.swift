//
//  dataModel.swift
//  DeskBreak_Test
//
//  Created by admin@33 on 02/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct UserRegistrationData {
    var username: String = ""
    var dateOfBirth: Date? = nil
    var email: String? // Make email optional
    var contactNumber: String = ""
    var password: String? // Make password optional
    var dailyTarget: Int16 = 0
    var profilePictureURL: String?
    var profilePicture: UIImage?
    var googleIDToken: String? // Add this property for Google Sign-In
    var googleAccessToken: String? // Add this property for Google Sign-In
    var appleIDToken: String?
    var appleUserIdentifier: String?
}

class ProfileImageCache {
    static let shared = ProfileImageCache()
    private init() {}

    var profileImage: UIImage?
}

class Shift {
    let morningShift = 9...17
    let lateShift = 17...1
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

struct Community {
    let communityId: String
    let communityName: String
    let communityCode: String
    let communityDescription: String?
    let placeName: String?
    let communityImageUrl: String?
    let createdBy: String
    let createdAt: Date
    let latitude: Double
    let longitude: Double
    let geohash: String
}

extension Community {
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.communityId = document.documentID
        self.communityName = data["communityName"] as? String ?? ""
        self.communityCode = data["communityCode"] as? String ?? ""
        self.communityDescription = data["communityDescription"] as? String ?? ""
        self.placeName = data["placeName"] as? String ?? ""
        self.communityImageUrl = data["communityImageUrl"] as? String ?? ""
        self.createdBy = data["createdBy"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.latitude = data["latitude"] as? Double ?? 0.0
        self.longitude = data["longitude"] as? Double ?? 0.0
        self.geohash = data["geohash"] as? String ?? ""
    }
}

func fetchCommunityDetails(communityIds: [String], completion: @escaping ([Community]) -> Void) {
    let db = Firestore.firestore()
    var communities: [Community] = []

    let group = DispatchGroup()

    for communityId in communityIds {
        group.enter()
        db.collection("communities").document(communityId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let community = Community(
                    communityId: communityId,
                    communityName: data?["communityName"] as? String ?? "",
                    communityCode: data?["communityCode"] as? String ?? "",
                    communityDescription: data?["communityDescription"] as? String ?? "",
                    placeName: data?["placeName"] as? String ?? "",
                    communityImageUrl: data?["communityImageUrl"] as? String ?? "",
                    createdBy: data?["createdBy"] as? String ?? "",
                    createdAt: (data?["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                    latitude: data?["latitude"] as? Double ?? 0.0,
                    longitude: data?["longitude"] as? Double ?? 0.0,
                    geohash: data?["geohash"] as? String ?? ""
                )
                communities.append(community)
            }
            group.leave()
        }
    }

    group.notify(queue: .main) {
        completion(communities)
    }
}

enum StretchType {
    case liftUp
    case neckFlex
    
    var title: String {
        switch self {
        case .liftUp:
            return "LiftUp"
        case .neckFlex:
            return "NeckFlex"
        }
    }
    
    var targetAreas: String {
        switch self {
        case .liftUp:
            return "Shoulder, Back"
        case .neckFlex:
            return "Neck"
        }
    }
}

struct Routine: Codable {
    var exerciseName: String
    var time: Date
    var weekdays: Set<WeekdayCode>
    var reminderEnabled: Bool
    
    func nextOccurrence(after date: Date) -> Date? {
        let calendar = Calendar.current
        let targetTime = calendar.dateComponents([.hour, .minute], from: time)
        
        var nextOccurrence = date
        while true {
            let weekday = calendar.component(.weekday, from: nextOccurrence)
            let weekdayCode = WeekdayCode(rawValue: weekday)!
            
            if weekdays.contains(weekdayCode) {
                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextOccurrence)
                components.hour = targetTime.hour
                components.minute = targetTime.minute
                
                let candidate = calendar.date(from: components)!
                if candidate > date {
                    return candidate
                }
            }
            
            nextOccurrence = calendar.date(byAdding: .day, value: 1, to: nextOccurrence)!
        }
    }
}

enum WeekdayCode: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
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
