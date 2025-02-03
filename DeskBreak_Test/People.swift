//
//  People.swift
//  DeskBreak_Test
//
//  Created by admin33 on 03/10/24.
//

import Foundation

struct Users {
    var name : String
    var dob : String
    var progress : Double
    var contact : String
    var email : String
    var Password : String
    var profilePic : String
}

let storedUser = Users(name: "Akshat Dutt Kaushik",
                       dob: "13-01-2003", progress: 0,
                      contact: "9455276501",
                      email: "akshatduttk@gmail.com",
                       Password: "1234567890",
                      profilePic: "akshat")

var users: [Users] = [
    Users(name: "Akshat Dutt Kaushik", dob: "13-01-2003", progress: 20, contact: "9455276501", email: "akshatduttk@gmail.com", Password: "1234567890", profilePic: "akshat")
]

struct People {
    var name : String
    var description : String
    var points : String
    var picture : String
}

struct WeeklyPeople {
    var name : String
    var position : String
    var points : String
    var picture : String
}

