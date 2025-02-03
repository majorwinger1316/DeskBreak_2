////
////  PeopleDataModel.swift
////  DeskBreak_Test
////
////  Created by admin44 on 18/11/24.
////
//import Foundation
//
//import UIKit
//
//struct Person {
//    var name: String
//    var age: Int
//    var gender: String
//
//    var dailyGoal: Int
//    var achievedGoals: Int
//    var totalActiveDays: Int
//    var position: Int
////    var lastExercise: Exercise?
//    var awards: [String]
//    var height: Float
//    var weight: Float
//    var wheelchair: Bool
//    var image: String
//    var points: Int
//    var communityCodes: [String]
//    var weeklyPoints: [Int]
//    var loginData: LoginData
//}
//
//struct LoginData: Codable {
//    var email: String
//    var Password: String
//    var progress : Int
//    var dob: String
//    var contact: String
//    var profilePic: String
//}
//
//var sampleUsers: [Person] = [
//    Person(
//        name: "Rohit Mehra",
//        age: 28,
//        gender: "Male",
//        dailyGoal: 600,
//        achievedGoals: 250,
//        totalActiveDays: 300,
//        position: 1,
//        awards: ["Marathon Finisher", "Step Challenge Winner"],
//        height: 5.8,
//        weight: 72.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 4500,
//        communityCodes: ["1010", "2020", "3030"],
//        weeklyPoints: [600, 620, 640, 650],
//        loginData: LoginData(
//            email: "rohit.mehra@example.com",
//            Password: "rohitpassword",
//            progress: 25,
//            dob: "10-05-1996",
//            contact: "9876543210",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Aditi Rao",
//        age: 24,
//        gender: "Female",
//        dailyGoal: 550,
//        achievedGoals: 180,
//        totalActiveDays: 240,
//        position: 2,
//        awards: ["Yoga Master", "Cycling Enthusiast"],
//        height: 5.5,
//        weight: 62.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 3800,
//        communityCodes: ["4040", "5050"],
//        weeklyPoints: [580, 600, 610, 620],
//        loginData: LoginData(
//            email: "aditi.rao@example.com",
//            Password: "aditipassword",
//            progress: 25,
//            dob: "18-03-2000",
//            contact: "9123456789",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Karan Singh",
//        age: 26,
//        gender: "Male",
//        dailyGoal: 500,
//        achievedGoals: 200,
//        totalActiveDays: 275,
//        position: 3,
//        awards: ["Fitness Guru", "Push-Up Champion"],
//        height: 6.0,
//        weight: 75.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 3600,
//        communityCodes: ["6060", "7070", "8080"],
//        weeklyPoints: [500, 520, 540, 560],
//        loginData: LoginData(
//            email: "karan.singh@example.com",
//            Password: "karanpassword",         progress: 25,
//            dob: "14-07-1998",
//            contact: "9812345678",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Meera Nair",
//        age: 22,
//        gender: "Female",
//        dailyGoal: 450,
//        achievedGoals: 150,
//        totalActiveDays: 200,
//        position: 4,
//        awards: ["Step Tracker Pro", "Mindful Meditator"],
//        height: 5.4,
//        weight: 58.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 3200,
//        communityCodes: ["9090", "1011", "1112"],
//        weeklyPoints: [450, 470, 480, 500],
//        loginData: LoginData(
//            email: "meera.nair@example.com",
//            Password: "meerapassword",
//            progress: 50,
//            dob: "22-08-2002",
//            contact: "9009876543",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Sameer Khan",
//        age: 27,
//        gender: "Male",
//        dailyGoal: 400,
//        achievedGoals: 130,
//        totalActiveDays: 185,
//        position: 5,
//        awards: ["Cardio King", "Run Tracker Elite"],
//        height: 5.9,
//        weight: 68.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 2800,
//        communityCodes: ["1213", "1314"],
//        weeklyPoints: [400, 420, 430, 450],
//        loginData: LoginData(
//            email: "sameer.khan@example.com",
//            Password: "sameerpassword",
//            progress: 15,
//            dob: "02-12-1997",
//            contact: "9876544321",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Priya Verma",
//        age: 29,
//        gender: "Female",
//        dailyGoal: 480,
//        achievedGoals: 160,
//        totalActiveDays: 210,
//        position: 6,
//        awards: ["Community Helper", "Fitness Journey Inspiration"],
//        height: 5.6,
//        weight: 64.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 3000,
//        communityCodes: ["1415", "1516", "1617"],
//        weeklyPoints: [470, 480, 490, 500],
//        loginData: LoginData(
//            email: "priya.verma@example.com",
//            Password: "priyapassword",
//            progress: 20,
//            dob: "15-09-1995",
//            contact: "9876598765",
//            profilePic: "person.fill"
//        )
//    ),
//    Person(
//        name: "Akshat Dutt Kaushik",
//        age: 21,
//        gender: "Male",
//        dailyGoal: 500,
//        achievedGoals: 120,
//        totalActiveDays: 180,
//        position: 7,
//        awards: ["Active Streak Holder", "Workout Warrior"],
//        height: 5.9,
//        weight: 75.0,
//        wheelchair: false,
//        image: "person.fill",
//        points: 3020,
//        communityCodes: ["1234", "5678", "9101"],
//        weeklyPoints: [500, 550, 600, 700],
//        loginData: LoginData(
//            email: "akshatduttk@gmail.com",
//            Password: "1234567890",
//            progress: 25,
//            dob: "13-01-2003",
//            contact: "9455276501",
//            profilePic: "person.fill"
//        )
//    )
//]
//
//// Current User
//var currentUser = Person(
//    name: "Akshat Dutt Kaushik",
//    age: 21,
//    gender: "Male",
//    dailyGoal: 500,
//    achievedGoals: 120,
//    totalActiveDays: 180,
//    position: 7,
//    awards: ["Active Streak Holder", "Workout Warrior"],
//    height: 5.9,
//    weight: 75.0,
//    wheelchair: false,
//    image: "person.fill",
//    points: 3020,
//    communityCodes: ["1234", "5678", "9101"],
//    weeklyPoints: [500, 550, 600, 700],
//    loginData: LoginData(
//        email: "akshatduttk@gmail.com",
//        Password: "1234567890",
//        progress: 25,
//        dob: "13-01-2003",
//        contact: "9455276501",
//        profilePic: "person.fill"
//    )
//)
